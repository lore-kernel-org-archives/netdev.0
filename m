From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Fri, 25 Apr 2008 14:35:08 -0700 (PDT)
Message-ID: <20080425.143508.38481200.davem@davemloft.net>
References: <d1c2719f0804241749p2c0dd7daofd343bc37a916247@mail.gmail.com>
	<20080424.234628.170849475.davem@davemloft.net>
	<d1c2719f0804251429l26118ef0j8a386103ee41f0ea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org, rick.jones2@hp.com
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58929
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759204AbYDYVfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 17:35:09 -0400
In-Reply-To: <d1c2719f0804251429l26118ef0j8a386103ee41f0ea@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jerry Chu" <hkchu@google.com>
Date: Fri, 25 Apr 2008 14:29:25 -0700

> Will get the latest 2.6.25 and take a look. I can't find "skb_release_all()"
> function you pointed in a later mail either. Guess the Linux kernel
> code is rewritten every few month :-(.

You want bugs fixed, like the one you reported here, don't you?
