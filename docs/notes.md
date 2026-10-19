# Notes from building it

Things we learned the hard way, which may save you the trouble.

**GemStone's notification interrupt was unreliable in a server gem.** It's delivered to whichever process happens to be running, often a request that's about to finish, and it isn't processed at all while every process waits on a socket. Polling the notify set is simpler, and hasn't missed a commit in any of our tests since.

**A stream must begin with the page's current render.** WebGS writes an event stream's headers before handing it over, so a page could see itself connected before it was subscribed, and miss a change. Sending the current render first closes the gap.

**WebGS's listener committed on every pass**, which made two gems conflict and stop each other. Tidewater's listener aborts instead, and commits only actions.

**A failed commit must be aborted.** A gem holding a conflict stops serving under WebGS. Every action now either commits or aborts.

**Rc classes didn't help.** They avoid conflicts on a hot root, but writing into one doesn't reliably signal the notify set. Roots stay plain, and conflicting actions retry.

**A transaction belongs to the gem, not the process.** An abort to see a new commit, from the poller or the listener, discarded the work of any action waiting partway through in another process. Actions that never wait were safe, since GemStone doesn't preempt processes, which is why it took an action with a `Delay` to see it. Now they take turns.

**Transcript waits for a line.** Warnings didn't reach a server's log until something else was printed. They're flushed now.
