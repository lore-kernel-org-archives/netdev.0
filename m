From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 21/26] net: mvneta: enable flow control for PHY connections
Date: Thu, 07 Jan 2016 12:31:49 -0800
Message-ID: <568ECB35.10907@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zkZ-00076c-1e@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33113 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874AbcAGUc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:32:26 -0500
Received: by mail-pa0-f47.google.com with SMTP id cy9so267047090pac.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:32:25 -0800 (PST)
In-Reply-To: <E1a5zkZ-00076c-1e@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:38, Russell King wrote:
> Enable flow control support for PHY connections by indicating our
> support via the ethtool capabilities.  phylink takes care of the
> appropriate handling.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
