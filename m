From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net 0/6] net_tstamp: Validate hwtstamp_config completely
 before applying it
Date: Thu, 14 Nov 2013 14:26:01 +0100
Message-ID: <20131114132600.GA25293@netboy>
References: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:59432 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753410Ab3KNN0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 08:26:06 -0500
Received: by mail-wi0-f178.google.com with SMTP id hn6so2484508wib.5
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 05:26:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 12:39:02AM +0000, Ben Hutchings wrote:
> This series fixes very similar bugs in 6 implementations of
> SIOCSHWTSTAMP.
> 
> Ben.
> 
> Ben Hutchings (6):
>   tg3: Validate hwtstamp_config completely before applying it
>   e1000e: Validate hwtstamp_config completely before applying it
>   pch_gbe: Validate hwtstamp_config completely before applying it
>   stmmac: Validate hwtstamp_config completely before applying it
>   ti_cpsw: Validate hwtstamp_config completely before applying it
>   ixp4xx_eth: Validate hwtstamp_config completely before applying it

For the series,

Acked-by: Richard Cochran <richardcochran@gmail.com>
