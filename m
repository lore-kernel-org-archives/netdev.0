From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3960] New: Few errors in pktgen.c
Date: Wed, 29 Dec 2004 13:48:01 -0800
Message-ID: <20041229134801.7e31e1cf.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 29 Dec 2004 04:13:51 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3960] New: Few errors in pktgen.c 


http://bugme.osdl.org/show_bug.cgi?id=3960

           Summary: Few errors in pktgen.c
    Kernel Version: >=2.6.10
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: nmalykh@bilim.com


Distribution: All
Hardware Environment: All
Software Environment: All
Problem Description: Incorrect parameters handling in pktgen.c

Steps to reproduce: Try to use pktgen without srcmac, src_mac_count and
MACSRC_RND. Source MAC header fields in generated frames will be
00:00:00:00:00:00 instead interface MAC

I've correct version of this module.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
