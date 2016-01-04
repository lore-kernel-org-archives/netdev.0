From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 07/24] phy: phy_{read|write}_mmd_indirect:
 get addr from phydev
Date: Mon, 04 Jan 2016 12:10:07 -0800
Message-ID: <568AD19F.8060000@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-8-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36755 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbcADUKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 15:10:38 -0500
Received: by mail-pf0-f196.google.com with SMTP id q63so18482488pfb.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 12:10:38 -0800 (PST)
In-Reply-To: <1451929022-5580-8-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> The address of the device can be determined from the phydev structure,
> rather than passing it as a parameter.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
