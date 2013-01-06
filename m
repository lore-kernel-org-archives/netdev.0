From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: report correct hardware stamping info to
 ethtool
Date: Sun, 6 Jan 2013 09:09:29 +0100
Message-ID: <20130106080929.GA2276@netboy.at.omicron.at>
References: <1357436318-12425-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.or, netdev@vger.kernel.org,
	s.hauer@pengutronix.de
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:55436 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751062Ab3AFIJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 03:09:41 -0500
Received: by mail-ee0-f50.google.com with SMTP id b45so8970977eek.23
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2013 00:09:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1357436318-12425-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 06, 2013 at 09:38:38AM +0800, Frank Li wrote:
> Report correct hardware stamping capibilty by ethtool interface.
> The v1.0 ptp4l check it.
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec.c |   28 +++++++++++++++++++++++++++-
>  1 files changed, 27 insertions(+), 1 deletions(-)

Thanks for following up to add this.

Acked-by: Richard Cochran <richardcochran@gmail.com>
