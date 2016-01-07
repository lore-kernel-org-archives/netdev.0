From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 07/26] phy: marvell: 88E1512: add flow control support
Date: Thu, 07 Jan 2016 11:53:34 -0800
Message-ID: <568EC23E.6040003@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zjP-000756-9Y@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35030 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883AbcAGTyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 14:54:08 -0500
Received: by mail-pa0-f48.google.com with SMTP id ho8so5516623pac.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 11:54:08 -0800 (PST)
In-Reply-To: <E1a5zjP-000756-9Y@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:37, Russell King wrote:
> The Marvell PHYs support pause frame advertisments, so we should not be
> masking their support off.  Add the necessary flag to the Marvell PHY
> to allow any MAC level pause frame support to be advertised.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
