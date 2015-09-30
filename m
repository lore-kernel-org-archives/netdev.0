From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/4] net: phy: Broadcom iProc MDIO bus driver
Date: Wed, 30 Sep 2015 14:36:29 -0700
Message-ID: <560C55DD.2040805@gmail.com>
References: <1443645163-2822-1-git-send-email-arunp@broadcom.com> <1443645163-2822-3-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com
To: Arun Parameswaran <arunp@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33170 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932845AbbI3Vgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 17:36:44 -0400
In-Reply-To: <1443645163-2822-3-git-send-email-arunp@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/09/15 13:32, Arun Parameswaran wrote:
> This patch adds support for the Broadcom iProc MDIO bus interface.
> The MDIO interface can be found in the Broadcom iProc family Soc's.
> 
> The MDIO bus is accessed using a combination of command and data
> registers. This MDIO driver provides access to the Etherent GPHY's
> connected to the MDIO bus.
> 
> Signed-off-by: Arun Parameswaran <arunp@broadcom.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
