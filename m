From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 net-next 1/4] bnx2x: Add Private Flags Support
Date: Thu, 23 May 2013 17:33:30 +0100
Message-ID: <1369326810.6963.5.camel@bwh-desktop.uk.level5networks.com>
References: <1369293712-26541-1-git-send-email-yuvalmin@broadcom.com>
	 <1369293712-26541-2-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<ariele@broadcom.com>, <eilong@broadcom.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34777 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417Ab3EWQdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 12:33:33 -0400
In-Reply-To: <1369293712-26541-2-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-23 at 10:21 +0300, Yuval Mintz wrote:
> Utilize ethtool's callback `get_priv_flags' - shed more light on the
> feasibility of devices as storage interfaces.
> 
> CC: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
[...]

This appears to implement the API correctly.

Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
