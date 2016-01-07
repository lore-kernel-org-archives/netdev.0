From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 16/26] phy: fixed-phy: remove fixed_phy_update_state()
Date: Thu, 07 Jan 2016 12:15:40 -0800
Message-ID: <568EC76C.40803@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zk9-000765-Dl@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35333 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380AbcAGUQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:16:14 -0500
Received: by mail-pa0-f42.google.com with SMTP id ho8so5925422pac.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:16:14 -0800 (PST)
In-Reply-To: <E1a5zk9-000765-Dl@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:38, Russell King wrote:
> mvneta is the only user of fixed_phy_update_state(), which has been
> converted to use phylink instead.  Remove fixed_phy_update_state().
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
