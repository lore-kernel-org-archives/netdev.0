From: David Miller <davem@davemloft.net>
Subject: Re: XTP for 2.6.25
Date: Fri, 25 Apr 2008 01:28:42 -0700 (PDT)
Message-ID: <20080425.012842.239066929.davem@davemloft.net>
References: <18b669d80804240606n47854939x94278f8d974034c1@mail.gmail.com>
	<18b669d80804250059m793f3f56xc4fdb8bad949fa3@mail.gmail.com>
	<Pine.LNX.4.64.0804251115470.2363@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shigeonx@gmail.com, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37844
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752555AbYDYI2n convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 04:28:43 -0400
In-Reply-To: <Pine.LNX.4.64.0804251115470.2363@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 25 Apr 2008 11:23:58 +0300 (EEST)

> Where these results with 2.6.25 as well? ...John Heffner just couple =
of=20
> days ago fixed reordering related problem in TCP (in case that netem=20
> parametrization causes reordering), the fix is not even in 2.6.24.y, =
I=20
> think...

Right, I didn't submit it there yet but I will make sure it
hits -stable in the next round.
