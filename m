From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] broadcom: Add 5241 support
Date: Wed, 16 Jun 2010 16:35:09 +0100
Message-ID: <1276702509.2114.35.camel@achroite.uk.solarflarecom.com>
References: <1276699126-8168-1-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:56694 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758772Ab0FPPfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 11:35:14 -0400
In-Reply-To: <1276699126-8168-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-16 at 18:38 +0400, Dmitry Eremin-Solenikov wrote:
> This patch adds the 5241 PHY ID to the broadcom module.
[...]

You need to add the ID and mask to the module device ID table
(broadcom_tbl) as well.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

