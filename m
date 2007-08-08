From: "Jean-Baptiste Vignaud" <vignaud@xandmail.fr>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Wed,  8 Aug 2007 10:59:22 +0200
Message-ID: <JMG6AY$2339D4FEA804188F4C6D4F66006A6BB6@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "cebbert" <cebbert@redhat.com>, "mingo" <mingo@elte.hu>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	"tglx" <tglx@linutronix.de>,
	"torvalds" <torvalds@linux-foundation.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"shemminger" <shemminger@linux-foundation.org>,
	"linux-net" <linux-net@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>,
	"akpm" <akpm@linux-foundation.org>,
	"alan" <alan@lxorguk.ukuu.org.uk>
To: "jarkao2" <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.xandmail.com ([212.155.184.97]:55019 "EHLO
	mail.xandmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867AbXHHJAm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 05:00:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Jean-Baptiste: I'm not sure how much of this testing you can afford?
> If you can spare some time for this and your box isn't for
> 'production' it could be very precious to diagnose such reproducible
> bug.

Well i can continue testing patches for sure.

> Then, I'd have a few suggestions (you could choose any of them) like:
> - trying these last test patches prepared for Marcin, too (but only
> with kernels 2.6.21 - 2.6.23-rc1),

I'v patched 2.6.23-rc2 with those patches yesterday evening, and
launched samba copy. 
Is rc2 ok ?

This morning the network is still up :
RX bytes:279853499958 (260.6 GiB)  TX bytes:7416695531 (6.9 GiB)

Still testing.

> If you would like to read something more about testing (then of
> course my suggestions could occur invalid - I'm a very bad tester
> myself...) you can try this:
> http://www.stardust.webpages.pl/files/handbook/

I'll have a look at the document. 

Jb


