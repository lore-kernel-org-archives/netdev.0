From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 1148] New: when using ipsec with DSL
 connections communication will hang if mtu is 1500(the default value)
Date: Tue, 26 Aug 2003 00:39:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030826003949.78ea3d07.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: uwe.schmeling@t-online.de
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 26 Aug 2003 00:07:57 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 1148] New: when using ipsec with DSL connections communication will hang if mtu is 1500(the default value)


http://bugme.osdl.org/show_bug.cgi?id=1148

           Summary: when using ipsec with DSL connections communication will
                    hang if mtu is 1500(the default value)
    Kernel Version: 2.6.0-test4
            Status: NEW
          Severity: normal
             Owner: bugme-janitors@lists.osdl.org
         Submitter: uwe.schmeling@t-online.de


Distribution:
Hardware Environment:
Software Environment:
Problem Description:

Steps to reproduce: 
Startup a tunneling connection, if one of the gw interfaces has mtu=1500,
communication will hang after transfering some data through tunnel. As far as I
know the problem will occure with DSL connections only.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
