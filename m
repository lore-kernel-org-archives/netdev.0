From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qla3xxx: add missing __iomem annotation
Date: Mon, 28 Feb 2011 12:42:32 -0800 (PST)
Message-ID: <20110228.124232.229751060.davem@davemloft.net>
References: <20110223095427.38a67186@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ron.mercer@qlogic.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56404
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752853Ab1B1Ul4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 15:41:56 -0500
In-Reply-To: <20110223095427.38a67186@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 23 Feb 2011 09:54:27 -0800

> Add necessary annotations about pointer to io memory space
> that is checked by sparse.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
