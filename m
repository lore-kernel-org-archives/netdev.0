From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 29/34]bnx2x: 1G-10G toggling race
Date: Sat, 17 Jan 2009 23:23:15 -0800 (PST)
Message-ID: <20090117.232315.174865846.davem@davemloft.net>
References: <1231951453.11301.150.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yanivr@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33463
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758756AbZARHXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 02:23:14 -0500
In-Reply-To: <1231951453.11301.150.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:44:13 +0200

> The HW should be configured so fast toggling between 1G and 10G will not be
> missed. Make sure that the HW is re-configured in full
> 
> Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
