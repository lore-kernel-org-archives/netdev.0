From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Revive VLAN support
Date: Mon, 26 Jan 2009 14:33:47 -0800 (PST)
Message-ID: <20090126.143347.147047233.davem@davemloft.net>
References: <20090126205043.GA15581@oksana.dev.rtsoft.ru>
	<324701F1-4A84-41A6-BC2D-4A61A8E135D9@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, jgarzik@pobox.com,
	dai.haruki@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32936
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752518AbZAZWdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 17:33:45 -0500
In-Reply-To: <324701F1-4A84-41A6-BC2D-4A61A8E135D9@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Mon, 26 Jan 2009 15:07:37 -0600

> 
> On Jan 26, 2009, at 2:50 PM, Anton Vorontsov wrote:
> 
> > commit 77ecaf2d5a8bfd548eed3f05c1c2e6573d5de4ba ("gianfar: Fix VLAN
> > HW feature related frame/buffer size calculation") wrongly removed
> > priv->vlgrp assignment, and now priv->vlgrp is always NULL.
 ...
> > Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> 
> Acked-by: Andy Fleming <afleming@freescale.com>

Applied, thanks guys.
