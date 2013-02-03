From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1] net-bnx2x: Force link UP when the interface is in
 LOOPBACK mode
Date: Sat, 02 Feb 2013 22:59:34 -0500 (EST)
Message-ID: <20130202.225934.1499362981458194042.davem@davemloft.net>
References: <1359565212-11104-1-git-send-email-maheshb@google.com>
	<1359618524.26518.3.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, yanivr@broadcom.com, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54660 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993Ab3BCD7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2013 22:59:36 -0500
In-Reply-To: <1359618524.26518.3.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Thu, 31 Jan 2013 09:48:44 +0200

> On Wed, 2013-01-30 at 09:00 -0800, Mahesh Bandewar wrote:
>> When the interface does not have carrier but when it's put into
>> loopback mode (for tests), it does not make sense to not have
>> the carrier. So force it!
>> 
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> 
> Thanks Mahesh!
> Acked-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
