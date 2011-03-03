From: Hans Nieser <hnsr@xs4all.nl>
Subject: Re: Mass udp flow reboot linux with RealTek RTL-8169 Gigabit
Date: Thu, 03 Mar 2011 20:53:25 +0100
Message-ID: <1299182005.28968.9.camel@krikkit>
References: <1298396007.23906.27.camel@krikkit>
	 <20110223095538.GA12662@electric-eye.fr.zoreil.com>
	 <1298463704.31256.29.camel@krikkit>  <1298485893.31256.40.camel@krikkit>
	 <1298641542.18103.48.camel@krikkit>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298641542.18103.48.camel@krikkit>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-02-25 at 14:45 +0100, Hans Nieser wrote:
...
> I've also attempted to bisect the issue I have been having with slow
> transfer speed (I don't know if its related to the hang, but I figure if
> the hang ever gets fixed, this will have to be fixed as well to make
> r8169 usable for me)
...

Just wanted to let you know that after installing a new Intel gbit NIC I
ordered, I sadly still get poor performance, so this is definitely a
separate issue from the r8169 lock up. (lock ups are gone now)

I've given up on getting r8169 working at this point but if you have any
patches you need tested or need more info in the future please do let me
know
