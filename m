From: Meelis Roos <mroos@linux.ee>
Subject: ipv6: no link-local address in 2.6.9
Date: Thu, 21 Oct 2004 11:12:33 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.44.0410211110280.8460-100000@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

since upgrading to 2.6.9 (actually yesterdays and todyas BK snapshots),
my e100 NIC does not get a link-local ipv6 address. ipv6 module is
loaded and lo has a ::1 address. Currently I have no ipv6 router in this
network but it still should get a link-local address? Or not anymore?

-- 
Meelis Roos (mroos@linux.ee)
