From: David Miller <davem@davemloft.net>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Sun, 31 Aug 2008 21:10:05 -0700 (PDT)
Message-ID: <20080831.211005.22750451.davem@davemloft.net>
References: <20031.1220236756@turing-police.cc.vt.edu>
	<20080831.205145.225080276.davem@davemloft.net>
	<6720.1220242094@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, jmalicki@metacarta.com, andi@firstfloor.org,
	johnpol@2ka.mipt.ru, dada1@cosmosbay.com, denys@visp.net.lb,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	juhlenko@akamai.com, sammy@sammy.net
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46156
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752377AbYIAEKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 00:10:11 -0400
In-Reply-To: <6720.1220242094@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valdis.Kletnieks@vt.edu
Date: Mon, 01 Sep 2008 00:08:14 -0400

> Quite frankly, unless somebody *IS* planning to become an expert on how the
> IT stuff for them are designed and run, we *should not* be doing any code
> changes that we don't understand, just because they say so and we should
> trust them...

Exactly!  We should not change where and how packet timestamps are
taken!  Thanks!

It is what I have been advocating this whole thread :-)
