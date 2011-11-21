From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Change mii to ethtool advertisement function names
Date: Mon, 21 Nov 2011 23:11:41 +0000
Message-ID: <1321917101.2692.16.camel@bwh-desktop>
References: <1321576255-29827-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:14580 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab1KUXLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 18:11:46 -0500
In-Reply-To: <1321576255-29827-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-17 at 16:30 -0800, Matt Carlson wrote:
> This patch implements advice by Ben Hutchings to change the mii side of
> the function names to look more like the register whose values they
> convert.  New LPA translation functions have been added as well.

Thanks Matt.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
