From: Mauro Tortonesi <mauro@deepspace6.net>
Subject: IPv6 packet forging
Date: Sat, 18 Jan 2003 15:54:12 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0301181523070.3466@trantor.ferrara.linux.it>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: Deep Space 6 Development Mailing List <ds6-devel@deepspace6.net>,
   USAGI Users Mailing List <usagi-users@linux-ipv6.org>,
   Linux Kernel Networking Stack Development Mailing List <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


hi to everybody,

	i am writing an IPv6 packet forger for linux. until now, to inject
packets on the net i have used link layer sockets, but i'd like to know if
there are more portable ways to perform the same task. do you know if
there is a BPF port for linux? or can i inject packets using tun/tap
driver?

-- 
Aequam memento rebus in arduis servare mentem...

Mauro Tortonesi			mauro@deepspace6.net
				mauro@ferrara.linux.it
Deep Space 6 - IPv6 on Linux	http://www.deepspace6.net
Ferrara Linux Users Group	http://www.ferrara.linux.it
