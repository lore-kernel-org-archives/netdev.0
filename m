From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: fec_mpc52xx: Read MAC address from device-tree
Date: Tue, 12 Feb 2013 16:16:34 -0500 (EST)
Message-ID: <20130212.161634.379840915476776959.davem@davemloft.net>
References: <1360674338-12776-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, agust@denx.de
To: sr@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57141 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759501Ab3BLVQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 16:16:35 -0500
In-Reply-To: <1360674338-12776-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Roese <sr@denx.de>
Date: Tue, 12 Feb 2013 14:05:38 +0100

> v3:
> - Use of_get_mac_address() instead of of_get_property()

Just to clarify, I applied this version (v3), not v2 (which I
just replied to with "applied").
