From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.23][BNX2]: Add PHY workaround for 5709 A1.
Date: Thu, 20 Sep 2007 11:05:20 -0700 (PDT)
Message-ID: <20070920.110520.24203599.davem@davemloft.net>
References: <1190311633.6934.1.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49518
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750718AbXITSFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 14:05:20 -0400
In-Reply-To: <1190311633.6934.1.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 20 Sep 2007 11:07:13 -0700

> [BNX2]: Add PHY workaround for 5709 A1.
> 
> Add the DIS_EARLY_DAC PHY workaround for 5709 A1.  Without it, link
> sometimes does not come up.
> 
> Update version to 1.6.5.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
