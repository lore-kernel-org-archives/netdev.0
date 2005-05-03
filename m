From: Stephen Hemminger <shemminger@osdl.org>
Subject: Fw: [Bug 4554] New: /proc/net/route missing info for 127.0.0.1/8
Date: Tue, 3 May 2005 14:36:03 -0700
Message-ID: <20050503143603.4d77d3dd@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 27 Apr 2005 09:05:29 -0700
From: bugme-daemon@osdl.org
To: shemminger@osdl.org
Subject: [Bug 4554] New: /proc/net/route missing info for 127.0.0.1/8


http://bugme.osdl.org/show_bug.cgi?id=4554

           Summary: /proc/net/route missing info for 127.0.0.1/8
    Kernel Version: kernel-2.6.9-5.0.3.EL
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: alex@milivojevic.org


Distribution: CentOS 4 (RHEL4)
Hardware Environment: i686
Problem Description:
cat /proc/net/route is missing information for 127.0.0.1/8 network (lo
interface).  On 2.4 kernels, this info was present (just checked on an old RH7.3
machine).  It seems to be missing on 2.6 kernels.  Bug?  Feature?  Omission?

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
