From: Pekka Savola <pekkas@netcore.fi>
Subject: netfilter6: REJECT target?
Date: Wed, 13 Aug 2003 23:30:49 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308132329050.15288-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Is there some reason the IPv6 Netfilter REJECT target hasn't been merged 
during the last 2 years it has existed in Netfilter's patch-o-matic.

(it hasn't been pushed for merging, sure, ...)

Just wondering why we are keeping Netfilter6 crippled like this.  Unless 
we can properly use it to reject packets with ICMPv6/TCP-RST, it's pretty 
close to useless :-(

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
