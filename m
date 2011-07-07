From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net next] bnx2x: Add dcbnl notification
Date: Thu, 07 Jul 2011 05:11:49 -0700 (PDT)
Message-ID: <20110707.051149.1742264258018821948.davem@davemloft.net>
References: <1310046941.22577.20.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: shmulikr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34044 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755887Ab1GGMLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 08:11:51 -0400
In-Reply-To: <1310046941.22577.20.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shmulik Ravid" <shmulikr@broadcom.com>
Date: Thu, 7 Jul 2011 16:55:41 +0300

> This patch adds a dcbnl notification to the bnx2x. The notification is
> sent to user mode clients following a change in the dcb negotiated
> parameters as resolved by the embedded DCBX stack. 
> 
> Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
