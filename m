From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: PROBLEM: network driver causes kernel panic
Date: Sat, 05 Jun 2004 22:43:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m38yf1viq3.fsf@defiant.pm.waw.pl>
References: <200406051215.i55CF4hH004189@harpo.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, dctucker@hotmail.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mikael Pettersson <mikpe@csd.uu.se>
In-Reply-To: <200406051215.i55CF4hH004189@harpo.it.uu.se> (Mikael
 Pettersson's message of "Sat, 5 Jun 2004 14:15:04 +0200 (MEST)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mikael Pettersson <mikpe@csd.uu.se> writes:

> Booting 2.6.7-rc1 with the de2104x driver built-in and eth0
> disconnected from the LAN leads to the following oops about
> a second after INIT tried to ifup eth0:
>
> eth0: timeout expired stopping DMA
> kernel BUG in de_set_media at drivers/net/tulip/de2104x.c:919!

Same here, i386, SMC EtherPower^2 (dual 21040 + 21050 PCI bridge).
-- 
Krzysztof Halasa, B*FH
