From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: r8169 and tg3
Date: Wed, 19 Nov 2003 19:44:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16315.47657.228084.388046@robur.slu.se>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com>
	<3FB9A277.70309@pobox.com>
	<20031118135848.A2451@electric-eye.fr.zoreil.com>
	<3FBBA76B.4070606@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, Brad House <brad_mssw@gentoo.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3FBBA76B.4070606@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeff Garzik writes:

 > hehe.  I certainly don't object...  You probably want to look over the 
 > r8169 v1.6 that Brad posted a link to, since it does have some improved 
 > 8169 hardware support (modulo bugs, of course).

 Yes r8169 can be interesting... I played with it a bit from my head the 
 sending performance was about 900 kpps (pktgen) and RX very OK too about 
 780 kpps with just dropping the skb instead of doing netif_receive.

 Cheers.
						--ro
