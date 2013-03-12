From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] phy: add set_wol/get_wol functions
Date: Tue, 12 Mar 2013 11:41:18 -0400 (EDT)
Message-ID: <20130312.114118.1873795464181773810.davem@davemloft.net>
References: <1363046205-17239-1-git-send-email-michael@stapelberg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, buytenh@wantstofly.org, andrew@lunn.ch,
	thomas.petazzoni@free-electrons.com
To: michael@stapelberg.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54164 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755196Ab3CLPlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 11:41:08 -0400
In-Reply-To: <1363046205-17239-1-git-send-email-michael@stapelberg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Stapelberg <michael@stapelberg.de>
Date: Tue, 12 Mar 2013 00:56:44 +0100

> This allows ethernet drivers (such as the mv643xx_eth) to support
> Wake on LAN on platforms where PHY registers have to be configured
> for Wake on LAN (e.g. the Marvell Kirkwood based qnap TS-119P II).
> 
> Signed-off-by: Michael Stapelberg <michael@stapelberg.de>

Applied.
