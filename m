From: Balint Marton <cus@fazekas.hu>
Subject: RE: [PATCH] get_random_bytes returns the same on every boot
Date: Tue, 27 Jul 2004 20:01:57 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0407271951590.23550@cinke.fazekas.hu>
References: <C0170D0AF1277849A4B4518034F855DD0CFC2F@aiexchange.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eble, Dan" <DanE@aiinet.com>
In-Reply-To: <C0170D0AF1277849A4B4518034F855DD0CFC2F@aiexchange.ai.aiinet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, 

In my previous email, i wrote about a 40 computer test.
Today, I repeated my test, and although every computer got the right IP 
address, there were at least 7 lines of DHCPNAK in the dhcpd logfile.
So the system time alone is not as good as it looked like.

Cus
