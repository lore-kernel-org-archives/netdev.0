From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCHv1] net-bnx2x: Force link UP when the interface is in
 LOOPBACK mode
Date: Thu, 31 Jan 2013 09:48:44 +0200
Message-ID: <1359618524.26518.3.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1359565212-11104-1-git-send-email-maheshb@google.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Yaniv <yanivr@broadcom.com>, "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: "Mahesh Bandewar" <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4285 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754824Ab3AaHtu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 02:49:50 -0500
In-Reply-To: <1359565212-11104-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-30 at 09:00 -0800, Mahesh Bandewar wrote:
> When the interface does not have carrier but when it's put into
> loopback mode (for tests), it does not make sense to not have
> the carrier. So force it!
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Thanks Mahesh!
Acked-by: Eilon Greenstein <eilong@broadcom.com>
