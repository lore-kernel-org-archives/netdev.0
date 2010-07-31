From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] TI DaVinci EMAC : Implement interrupt pacing
 functionality.
Date: Fri, 30 Jul 2010 23:56:14 -0700 (PDT)
Message-ID: <20100730.235614.28817673.davem@davemloft.net>
References: <1280406840-27393-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com, nsekhar@ti.com,
	anantgole@ti.com
To: srk@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751104Ab0GaGz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 02:55:56 -0400
In-Reply-To: <1280406840-27393-1-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriramakrishnan <srk@ti.com>
Date: Thu, 29 Jul 2010 18:03:58 +0530

> DaVinci EMAC module includes an interrupt pacing block that can
> be programmed to throttle the rate at which interrupts are
> generated. This patch implements interrupt pacing logic that can
> be controlled through the ethtool interface(only rx_coalesce_usecs
> param is honored)
> 
> Signed-off-by: Sriramakrishnan <srk@ti.com>

Applied.
