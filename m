From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Sat, 05 Feb 2005 20:55:07 +0900 (JST)
Message-ID: <20050205.205507.75127320.yoshfuji@linux-ipv6.org>
References: <4204AA7C.9010509@tomt.net>
	<20050205.203900.66065862.yoshfuji@linux-ipv6.org>
	<4204B27F.5040202@tomt.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        mirko.parthey@informatik.tu-chemnitz.de, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, shemminger@osdl.org, yoshfuji@linux-ipv6.org
To: andre@tomt.net
In-Reply-To: <4204B27F.5040202@tomt.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <4204B27F.5040202@tomt.net> (at Sat, 05 Feb 2005 12:48:15 +0100), Andre Tomt <andre@tomt.net> says:

> > Please tell me, why your lo is down...
:
> "ifdown -a" gets run on shutdown and reboot here, and ifdown -a in 
> Debian brings down loopback before any other interfaces.

Okay, thanks. (I now remember someone told me this before.) hmm...

--yoshfuji
