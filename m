From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: which stable PCI DSL Modem card
Date: Tue, 30 Mar 2010 13:32:35 +0400
Message-ID: <4BB1C533.5010909@msgid.tls.msk.ru>
References: <hoqbhd$pod$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Markus Feldmann <feldmann_markus@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:36846 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756031Ab0C3Jch (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 05:32:37 -0400
In-Reply-To: <hoqbhd$pod$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Markus Feldmann Wrote:
> Hi All,
> 
> i am searching for a stable PCI DSL Modem card for Linux (Debian Lenny).
> It should be exist a driver in the Kernel not extra software driver. I
> have a 6000MBit/s DSL wire.
> 
> Does anybody know some interesting device for me? Any further information?

As far as I can see they stopped producing PCI DSL modems quite a while
ago.  They sell USB and ethernet ones, but not PCI.  And even at "old
good" times there were only 2 or 3 models with PCI interface, the rest
were USB or Ether.

I personally recommend ethernet modem - it will work with any OS including
linux.  USB modems with linux support exists, but that support is somewhat
flaky.

Also, many DSL modems nowadays comes with 4-port ethernet switch and
wireless access point, which may be handy too.  Both optional.

/mjt
