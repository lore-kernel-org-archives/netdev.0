From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Tue, 10 Nov 2015 15:04:03 -0500 (EST)
Message-ID: <20151110.150403.1195107307226924000.davem@davemloft.net>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	<1447178145.17135.75.camel@edumazet-glaptop2.roam.corp.google.com>
	<yw1xr3jxraqs.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, slash.tmp@free.fr
To: mans@mansr.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xr3jxraqs.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: M=E5ns Rullg=E5rd <mans@mansr.com>
Date: Tue, 10 Nov 2015 18:05:15 +0000

> Because I haven't been following the netdev list closely for the last
> five years, and no documentation I read mentioned this function.  I c=
an
> certainly change it.

It is always advisable to mimick what other drivers do and use them as
a reference, rather than depend upon documentation which by definition
is always going to be out of sync with the source tree.
