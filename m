From: "J. Simonetti" <jeroens@office.netland.nl>
Subject: 2.6.10 dst cache overflow
Date: Wed, 16 Feb 2005 11:40:13 +0100
Message-ID: <1108550412.3799.81.camel@ts2.office.netland.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi list,

I was directed to this list for my question. I searched many archives
but could not find any recent posts about this subject so I ask again.

I have a linux (Fedora core 3) based router. I does approximately 50Mbps
aggregated traffic. However once every week (approx) the router dies
with 'kernel: dst cache overflow' messages flooding syslog. I have
tracked it down to being an issue with the routing cache.

I was hoping someone here could give me some more information on how to
address this issue. In particular info about /proc/sys/net/route/* and
the meaning of its values (in essence the garbage collection routines).

Regards,

Jeroen Simonetti
--
Netland Internet Services
http://www.netland.nl

Never look up when dragons fly overhead.
