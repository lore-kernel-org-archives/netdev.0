From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 01/26] phy: move fixed_phy MII register generation
 to a library
Date: Thu, 07 Jan 2016 11:47:06 -0800
Message-ID: <568EC0BA.7040003@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5ziu-00074T-EQ@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35464 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181AbcAGTrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 14:47:40 -0500
Received: by mail-pa0-f42.google.com with SMTP id ho8so5397170pac.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 11:47:40 -0800 (PST)
In-Reply-To: <E1a5ziu-00074T-EQ@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:37, Russell King wrote:
> Move the fixed_phy MII register generation to a library to allow other
> software phy implementations to use this code.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
