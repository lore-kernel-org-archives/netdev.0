From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 03/26] phy: separate swphy state validation from register
 generation
Date: Thu, 07 Jan 2016 11:48:50 -0800
Message-ID: <568EC122.9080508@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zj4-00074f-PZ@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35437 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380AbcAGTtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 14:49:24 -0500
Received: by mail-pa0-f54.google.com with SMTP id ho8so5429070pac.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 11:49:24 -0800 (PST)
In-Reply-To: <E1a5zj4-00074f-PZ@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:37, Russell King wrote:
> Separate out the generation of MII registers from the state validation.
> This allows us to simplify the error handing in fixed_phy() by allowing
> earlier error detection.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
