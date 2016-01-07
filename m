From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 18/26] net: mvneta: add nway_reset support
Date: Thu, 07 Jan 2016 12:19:44 -0800
Message-ID: <568EC860.9060506@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zkJ-00076K-M7@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33816 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbcAGUUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:20:19 -0500
Received: by mail-pa0-f45.google.com with SMTP id uo6so248554932pac.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:20:19 -0800 (PST)
In-Reply-To: <E1a5zkJ-00076K-M7@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:38, Russell King wrote:
> Add ethtool nway_reset support to mvneta via phylink, so that userspace
> can request the link in whatever mode to be renegotiated via
> ethtool -r ethX.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
