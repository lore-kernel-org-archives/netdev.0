From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [IrDA] irda-usb needs firmware loader
Date: Wed, 27 Sep 2006 20:06:23 -0700 (PDT)
Message-ID: <20060927.200623.24202776.davem@davemloft.net>
References: <20060911054648.GB6368@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37800
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965243AbWI1DGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 23:06:24 -0400
To: samuel@sortiz.org
In-Reply-To: <20060911054648.GB6368@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Mon, 11 Sep 2006 08:46:48 +0300

> With the inclusion of the stir421x code, we now need to select FW_LOADER
> whenever we try to build the irda-usb code.
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied, thanks.
