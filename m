From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 08/26] phy: export phy_start_machine() for phylink
Date: Thu, 07 Jan 2016 11:53:48 -0800
Message-ID: <568EC24C.7060604@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zjU-00075C-Dn@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33109 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbcAGTyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 14:54:23 -0500
Received: by mail-pa0-f43.google.com with SMTP id cy9so266346824pac.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 11:54:23 -0800 (PST)
In-Reply-To: <E1a5zjU-00075C-Dn@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:37, Russell King wrote:
> phylink will need phy_start_machine exported, so lets export it as a
> GPL symbol.  Documentation/networking/phy.txt indicates that this
> should be a PHY API function.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
