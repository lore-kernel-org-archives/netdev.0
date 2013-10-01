From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool] sfc: Add support for EF10 registers
Date: Tue, 1 Oct 2013 16:36:54 +0100
Message-ID: <1380641814.1939.2.camel@bwh-desktop.uk.level5networks.com>
References: <1379952298.2485.35.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62693 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093Ab3JAPg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 11:36:58 -0400
In-Reply-To: <1379952298.2485.35.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 17:04 +0100, Ben Hutchings wrote:
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> This works in conjunction with the recently submitted driver change
> 'sfc: Add EF10 registers to register dump'.
> 
> Ben.
> 
>  sfc.c | 159 +++++++++++++++++++++++++++++++++++++++++++++---------------------
>  1 file changed, 109 insertions(+), 50 deletions(-)

I've now applied this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
