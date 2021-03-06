defmodule FibSolver do
  def cat(scheduler) do
    send scheduler, {:ready, self()}
    receive do
      {:cat, filepath, client} ->
        send client, {:answer, filepath, cat_process(filepath), self()}
        cat(scheduler)
      {:shutdown} ->
        exit(:normal)
    end
  end
  defp cat_process(filepath) do
    file = File.read!("cats/#{filepath}")
    String.match?(file, ~r/cat/)
  end
end 

defmodule Scheduler do
  def run(num_processes, module, func, to_calculate) do
    (1..num_processes)
      |> Enum.map(fn(_) -> spawn(module, func, [self()]) end)
      |> schedule_processes(to_calculate, [])
  end

  defp schedule_processes(processes, queue, results) do
    receive do
      {:ready, pid} when length(queue) > 0 ->
        [next | tail] = queue
        send pid, {:cat, next, self()}
        schedule_processes(processes, tail, results)
      {:ready, pid} ->
        send pid, {:shutdown}
        if length(processes) > 1 do
          schedule_processes(List.delete(processes, pid), queue, results)
        else
          Enum.sort(results, fn {n1,_}, {n2,_} -> n1 <= n2 end)
        end
      {:answer, number, result, _pid} ->
        schedule_processes(processes, queue, [{number, result} | results])
    end
  end
end

to_process = File.ls!("cats")
Enum.each 1..10, fn num_processes ->
  {time, result} = :timer.tc(
    Scheduler, :run, [num_processes, FibSolver, :cat, to_process]
  )
  if num_processes == 1 do
    IO.puts inspect result
    IO.puts "\n #time (s)"
  end
  :io.format "~2B ~.2f~n", [num_processes, time/1000000.0]
end 

# これだと差が出ない！のでひたすらコピーして10000ファイルで実験してみました

"""
 #time (s)
 1 0.40
 2 0.30
 3 0.26
 4 0.23
 5 0.22
 6 0.23
 7 0.22
 8 0.24
 9 0.25
10 0.24
"""

# また4コアでサチってるんですけど！そして1コアでもそんなに性能劣化していないという
# なんだろう、ファイルIOの限界性能の方で詰まってる気がする。1ファイルが16kbくらいあれば違うのかな
