From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 1243] New: Communication with ipsec api seems
 to hang after some operation
Date: Tue, 16 Sep 2003 09:48:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916094824.4a18c21c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 16 Sep 2003 03:54:55 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 1243] New: Communication with ipsec api seems to hang after some operation


http://bugme.osdl.org/show_bug.cgi?id=1243

           Summary: Communication with ipsec api seems to hang after some
                    operation
    Kernel Version: 2.6.0-test5
            Status: NEW
          Severity: normal
             Owner: bugme-janitors@lists.osdl.org
         Submitter: uwe.schmeling@t-online.de


Distribution: SuSe 8.2
Hardware Environment: ASUS P2B-D/ 2xPIII 800/ 1GB Ram
Software Environment: ipsec-tools-0.2.2
Problem Description: after a couple of operating hours (SA insert SA delete)
communication with PFKEY interface seems to hang (setkey -D doesn't respond
while  performing send to PFKEY interface) 

Steps to reproduce: Setup a VPN environment on the above environment using ESP4
tunnels

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
