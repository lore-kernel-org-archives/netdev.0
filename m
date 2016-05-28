From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC v2 1/2] NET: PHY: adds driver for Lantiq PHY11G
Date: Sat, 28 May 2016 19:55:05 +0200
Message-ID: <20160528175505.GI23212@lunn.ch>
References: <1464454741-18557-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, alexander.stein@systec-electronic.com,
	netdev@vger.kernel.org, john@phrozen.org, openwrt@kresin.me,
	hauke.mehrtens@intel.com, daniel.schwierzeck@gmail.com,
	eckert.florian@googlemail.com
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53435 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750742AbcE1RzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 May 2016 13:55:11 -0400
Content-Disposition: inline
In-Reply-To: <1464454741-18557-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 28, 2016 at 06:59:00PM +0200, Hauke Mehrtens wrote:

Hi Hauke

> +	/**
> +	 * In most cases only one LED is connected to this phy, so
> +	 * configure them all to constant on and plue mode. LED3 is

pulse not plue?

> +	 * only available in some packages, let it in its reset

leave, not let?

       Andrew
