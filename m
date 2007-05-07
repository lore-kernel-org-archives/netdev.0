From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 3/3] Intel IXP4xx network drivers
Date: Mon, 07 May 2007 22:00:20 +0200
Message-ID: <m3y7k08kvf.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3vef5biob.fsf@maximus.localdomain>
	<5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk>
	<m3hcqoa772.fsf@maximus.localdomain> <20070507175213.GU23611@tweety>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael-Luke Jones <mlj28@cam.ac.uk>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Russell King <rmk@arm.linux.org.uk>,
	Jeff Garzik <jeff@garzik.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Christian Hohnstaedt <chohnstaedt@innominate.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:54576 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966369AbXEGUAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 16:00:22 -0400
In-Reply-To: <20070507175213.GU23611@tweety> (Christian Hohnstaedt's message of "Mon, 7 May 2007 19:52:13 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christian Hohnstaedt <chohnstaedt@innominate.com> writes:

> - the NPE can also be used as DMA engine and for crypto operations.
>   Both are not network related.
>   Additionally, the NPE is not only ixp4xx related, but is
>   also used in IXP23xx CPUs, so it could be placed in
>   arch/arm/common or arch/arm/xscale ?
>
> - The MAC is used on IXP23xx, too. So the drivers for
>   both CPU familys only differ in the way they exchange
>   network packets between the NPE and the kernel.

Hmm... perhaps someone have a spare device with such IXP23xx
and wants to make it a donation for science? :-)
-- 
Krzysztof Halasa
