From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/7] caif: Rename functions in cfcnfg and
 caif_dev
Date: Wed, 28 Apr 2010 13:03:04 -0700 (PDT)
Message-ID: <20100428.130304.200392146.davem@davemloft.net>
References: <1272480880-30672-1-git-send-email-sjur.brandeland@stericsson.com>
	<1272480880-30672-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org,
	daniel.martensson@stericsson.com, sjurbr@gmail.com,
	linus.walleij@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57262
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932110Ab0D1UC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 16:02:58 -0400
In-Reply-To: <1272480880-30672-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Wed, 28 Apr 2010 20:54:35 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Changes:
>  o Renamed cfcnfg_del_adapt_layer to cfcnfg_disconn_adapt_layer
>  o Fixed typo cfcfg to cfcnfg
>  o Renamed linkid to channel_id
>  o Updated documentation in caif_dev.h
>  o Minor formatting changes
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied.
