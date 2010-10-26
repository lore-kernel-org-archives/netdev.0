From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation
Date: Mon, 25 Oct 2010 17:48:33 -0700
Message-ID: <AANLkTinxe7M-_bHdhA-jrW2gBtGLCXkBasSPi7RaFDi-@mail.gmail.com>
References: <E1PAVIx-0001qL-EB@smtp.tuxdriver.com>
	<1288045856.3296.19.camel@edumazet-laptop>
	<20101025233558.GA30118@hmsreliant.think-freely.org>
	<20101025.164646.104054845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nhorman@tuxdriver.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, jpirko@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42512 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab0JZAse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 20:48:34 -0400
Received: by wyf28 with SMTP id 28so4039576wyf.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 17:48:33 -0700 (PDT)
In-Reply-To: <20101025.164646.104054845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is http://bugzilla.redhat.com/637619

I'm the original reporter and I haven't yet fully vetted / tested the
patch (not directly related to my job and all that).
