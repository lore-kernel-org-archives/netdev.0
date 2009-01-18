From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 19/34]bnx2x: Disable napi
Date: Sat, 17 Jan 2009 23:17:40 -0800 (PST)
Message-ID: <20090117.231740.213142330.davem@davemloft.net>
References: <1231951419.11301.140.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45806
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756939AbZARHRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 02:17:39 -0500
In-Reply-To: <1231951419.11301.140.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:43:39 +0200

> Calling napi disabled unconditionally at netif stop
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
