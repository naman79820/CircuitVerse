Dir.chdir('/home/naman/projects/CircuitVerse')
stashes = `git stash list`.lines.map { |l| l.split(':').first }
stashes.each do |stash|
  diff = `git stash show -p #{stash}`
  if diff.include?('background-color: #f3f4f6')
    puts stash
    break
  end
end
