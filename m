From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [IrDA] Incorrect TTP header reservation
Date: Wed, 06 Dec 2006 20:09:19 -0800 (PST)
Message-ID: <20061206.200919.85705721.davem@davemloft.net>
References: <20061207005117.GB21131@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeetlinux@yahoo.co.in, irda-users@lists.sourceforge.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46780
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S968703AbWLGEJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 23:09:08 -0500
To: samuel@sortiz.org
In-Reply-To: <20061207005117.GB21131@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Thu, 7 Dec 2006 02:51:17 +0200

> We must reserve SAR + MAX_HEADER bytes for IrLMP to fit in.
> 
> Patch from Jeet Chaudhuri <jeetlinux@yahoo.co.in>
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Also applied.

Are you sending this patch to -stable?  Please do.
