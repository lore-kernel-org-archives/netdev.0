From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 09/26] phy: export phy_speed_to_str() for phylink
Date: Thu, 07 Jan 2016 11:54:04 -0800
Message-ID: <568EC25C.10401@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zjZ-00075I-Hc@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35304 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbcAGTyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 14:54:38 -0500
Received: by mail-pa0-f48.google.com with SMTP id ho8so5525515pac.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 11:54:38 -0800 (PST)
In-Reply-To: <E1a5zjZ-00075I-Hc@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:37, Russell King wrote:
> phylink would like to reuse phy_speed_to_str() to convert the speed
> to a string.  Add a prototype and export this helper function.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
