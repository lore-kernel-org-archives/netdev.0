From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 17/26] phylink: add ethtool nway_reset support
Date: Thu, 07 Jan 2016 12:24:26 -0800
Message-ID: <568EC97A.3060408@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zkE-00076C-He@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33006 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711AbcAGUZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:25:00 -0500
Received: by mail-pa0-f41.google.com with SMTP id cy9so266911389pac.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:24:59 -0800 (PST)
In-Reply-To: <E1a5zkE-00076C-He@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:38, Russell King wrote:
> Add ethtool nway_reset support to phylink, to allow userspace to
> request a re-negotiation of the link.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
