From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4274] New: ipv6: Unknown symbol
 tcp_timer_bug_msg
Date: Wed, 2 Mar 2005 09:19:07 -0800
Message-ID: <20050302091907.19bb2b2e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgoerzen@complete.org
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 2 Mar 2005 09:15:18 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4274] New: ipv6: Unknown symbol tcp_timer_bug_msg


http://bugme.osdl.org/show_bug.cgi?id=4274

           Summary: ipv6: Unknown symbol tcp_timer_bug_msg
    Kernel Version: 2.6.11
            Status: NEW
          Severity: normal
             Owner: yoshfuji@linux-ipv6.org
         Submitter: jgoerzen@complete.org


Distribution: Debian sid
Hardware Environment: alpha
Software Environment:
Problem Description:

modprobe ipv6 fails with:

ipv6: Unknown symbol tcp_timer_bug_msg

I saw this back on a previous version and submitted #3717 at the time.  The
patch attached to that bug worked.  However, 2.6.11 appears to include that
patch, and yet, I'm still getting this problem.

I will attach my config file.  Please let me know if you need any other information.

Thanks,
John Goerzen

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
