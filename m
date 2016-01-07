From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 14/26] sfp: display SFP module information
Date: Thu, 07 Jan 2016 12:23:46 -0800
Message-ID: <568EC952.2080507@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zjz-00075t-5x@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35744 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbcAGUYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:24:20 -0500
Received: by mail-pa0-f49.google.com with SMTP id ho8so6072275pac.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:24:20 -0800 (PST)
In-Reply-To: <E1a5zjz-00075t-5x@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:38, Russell King wrote:
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Looks useful, but also duplicates a bit what ethtool already does,
unless this is really useful to make decisions, I would probably drop
this entirely...

-- 
Florian
