From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] [IrDA] tsap init routine factorisation
Date: Mon, 02 Jul 2007 22:57:15 -0700 (PDT)
Message-ID: <20070702.225715.109569495.davem@davemloft.net>
References: <20070701221427.101308704@sortiz.org>
	<20070701221706.468909173@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	gl@dsa-ac.de
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56164
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753376AbXGCF4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 01:56:55 -0400
In-Reply-To: <20070701221706.468909173@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: samuel@sortiz.org
Date: Mon, 02 Jul 2007 01:14:31 +0300

> This patch extracts common code from irttp_open_tsap() and irttp_dup() 
> into a new function to 1) avoid code duplication, 2) help avoid forgetting 
> object initialization in the tsap duplication path in the future.
> 
> Signed-off-by: G. Liakhovetski <gl@dsa-ac.de>
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Also applied, thanks.
