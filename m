From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Fwd: That whole "Linux stealing our code" thing
Date: Sun, 2 Sep 2007 11:36:38 +0100
Message-ID: <20070902113638.78fbd202@the-village.bc.nu>
References: <200709010140.l811eq9H005896@cvs.openbsd.org>
	<f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com>
	<46D99FB7.6030505@garzik.org>
	<f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com>
	<20070901205457.GK9260@stusta.de>
	<f34ca13c0709011427u7a9cc97bp75c035afed3e5a63@mail.gmail.com>
	<20070901215225.GM9260@stusta.de>
	<f34ca13c0709011629g1f16508cic7c31c3d20a57dae@mail.gmail.com>
	<20070902000913.GB16016@stusta.de>
	<f34ca13c0709011753h7733089dt48570480a7a19baa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Adrian Bunk" <bunk@kernel.org>, "Jeff Garzik" <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "Jiri Slaby" <jirislaby@gmail.com>
To: "Constantine A. Murenin" <mureninc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:57004 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756078AbXIBK2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 06:28:13 -0400
In-Reply-To: <f34ca13c0709011753h7733089dt48570480a7a19baa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> - If you receive ISC or BSD licensed code, you may not delete the
>  license.  Same principle, since the notice says so.  It's the law.
>  Really.

You can shout this all you like but you would be wrong. You can remove
the licence if you have permission to do so. For the ath c files there
was permission to do so.

> My understanding is that with dual-licensed code, you choose to comply
> with all of the terms of either licence. However, you cannot simply
> remove either of these licences from the code, unless you specifically
> receive such right from the copyright holder (remember, with the
> copyright law, unless the rights are specifically given, they are
> retained). This is what Theo was trying to educate the community on. I
> don't see anything unethical in explaining the legal issues.

Your understanding isn't quite right. One of many things you may get with
dual licensed code is the right to pick a licence from several choices,
you may also get the right to remove some choices from the recipient.

A work that combines GPL and BSD licensed material is not the same as a
work which says I may choose between two licences. If both licences must
always apply (which is a perfectly possible condition to put in a
licence) then putting such a "both" GPL/BSD licence piece of code into
OpenBSD would require any OpenBSD distributed containing it was GPL
licenced when conveyed, which I am *very* sure is not the intent.

Thus what you appear to be doing by putting the ath5k C code in OpenBSD is
conveying it under the BSD licence (making a choice between the two
offered) and conveying a right for parties down the chain to convey it
under one of the licences only.

And as we've already established the header files are quite different.


Doesn't mean its not somewhat rude but illegal and rude are two very
different things.

