From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 11:06:25 +0000
Message-ID: <20080818110625.GA6910@ff.dom.local>
References: <20080818091011.GC5434@ff.dom.local> <20080818.023105.01989851.davem@davemloft.net> <20080818094727.GA6388@ff.dom.local> <20080818.031003.115715822.davem@davemloft.net> <20080818103559.GA6548@ff.dom.local> <20080818104355.GB6548@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Denys Fedoryshchenko <denys@visp.net.lb>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:30087 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbYHRLGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 07:06:32 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1113296nfc.21
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 04:06:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080818104355.GB6548@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 10:43:56AM +0000, Jarek Poplawski wrote:
...
> Sooory!!! Forget this all: it looks like your patch is damn right!

So, I guess, you could merge this patch to net-2.6, so Denys could
test this all later without additional patching?!

Jarek P.
