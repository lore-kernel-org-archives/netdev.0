From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]netdev: add driver for enc424j600 ethernet chip on SPI
 bus
Date: Mon, 24 Jan 2011 15:04:50 -0800 (PST)
Message-ID: <20110124.150450.48527021.davem@davemloft.net>
References: <AANLkTinosxXKgfkqGKqCLGi8tWeP4xnT1P3kMRu51CvS@mail.gmail.com>
	<AANLkTi=WQ-o+D0NicpGBd_qcfivLYaix_CUGWi2Rd_Zv@mail.gmail.com>
	<AANLkTi=F7n3fXr1EopYgoXTWkX7Wtx7dCs0x-t36871J@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mirqus@gmail.com, mohan@thotakaa.com,
	blue.cube@seznam.cz, lanconelli.claudio@eptar.com,
	sriram@thotakaa.com
To: balaji.v@thotakaa.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33099
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752478Ab1AXXEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 18:04:16 -0500
In-Reply-To: <AANLkTi=F7n3fXr1EopYgoXTWkX7Wtx7dCs0x-t36871J@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balaji Venkatachalam <balaji.v@thotakaa.com>
Date: Sun, 16 Jan 2011 16:21:45 +0530

> +/* use ethtool to change the level for any given device */
> +static struct {
> +	u32 msg_enable;
> +} debug = {
> +-1};

Please format this code reasonably.
