From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 20/26] net: mvneta: add flow control support via phylink
Date: Thu, 07 Jan 2016 12:26:14 -0800
Message-ID: <568EC9E6.9020504@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zkT-00076W-UC@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35061 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162AbcAGU0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:26:48 -0500
Received: by mail-pa0-f45.google.com with SMTP id ho8so6117176pac.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:26:48 -0800 (PST)
In-Reply-To: <E1a5zkT-00076W-UC@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:38, Russell King wrote:
> Add flow control support to mvneta, including the ethtool hooks.  This
> uses the phylink code to calculate the result of autonegotiation where
> a phy is attached, and to handle the ethtool settings.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Looks obviously correct from an API usage perpsective.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

-- 
Florian
