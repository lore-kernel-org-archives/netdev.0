From: David Miller <davem@davemloft.net>
Subject: Re: next-20090318: sunhme does not transmit packets
Date: Sun, 22 Mar 2009 21:51:10 -0700 (PDT)
Message-ID: <20090322.215110.261185328.davem@davemloft.net>
References: <a4423d670903180958j4847717eh99a41534633dd314@mail.gmail.com>
	<20090318.234451.38898787.davem@davemloft.net>
	<a4423d670903190116p157b2ebfl69d270e0576c6d9a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34416
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751431AbZCWEvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 00:51:22 -0400
In-Reply-To: <a4423d670903190116p157b2ebfl69d270e0576c6d9a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Thu, 19 Mar 2009 11:16:20 +0300

> 2009/3/19 David Miller <davem@davemloft.net>:
> > Does the current vanilla kernel work fine?
> 
> Yes. The problem happens only with -next tree.

I have one of my ultra10s up and will try to reproduce and diagnose
this locally.

Thanks.
