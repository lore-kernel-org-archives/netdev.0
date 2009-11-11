From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/4] bnx2x: GSO implies CSUM offload
Date: Tue, 10 Nov 2009 22:32:29 -0800 (PST)
Message-ID: <20091110.223229.238168560.davem@davemloft.net>
References: <1257782962.4101.40.camel@lb-tlvb-eilong>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59194
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752075AbZKKGcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:32:03 -0500
In-Reply-To: <1257782962.4101.40.camel@lb-tlvb-eilong>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 9 Nov 2009 18:09:22 +0200

> Making sure that whenever the FW/HW is configured for GSO, it is also configured
> to CSUM offload
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
