From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9]: sch_hfsc: Use ->requeue queue instead of ops.
Date: Wed, 20 Aug 2008 15:14:15 -0700 (PDT)
Message-ID: <20080820.151415.211743707.davem@davemloft.net>
References: <20080818.222917.10471071.davem@davemloft.net>
	<48AAC57E.1090504@trash.net>
	<20080820220931.GA3071@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56007
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754098AbYHTWOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 18:14:15 -0400
In-Reply-To: <20080820220931.GA3071@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 21 Aug 2008 00:09:32 +0200

> So, IMHO, if it's not going to be something really simple I doubt it's
> worth to bother with this. Anyway, I hope David will give some warning
> yet before merging this.

I still have to pour over all of this feedback, so don't
worry I won't be merging anything like this any time soon :)
