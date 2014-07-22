From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v2 00/11] net: bcmgenet: PM and Wake-on-LAN
Date: Tue, 22 Jul 2014 22:20:20 +0200
Message-ID: <20140722202020.GA13637@electric-eye.fr.zoreil.com>
References: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59138 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460AbaGVUUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 16:20:24 -0400
Content-Disposition: inline
In-Reply-To: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> :
[...]
> This patchset brings S2/S3 Power Management support to the GENET driver
> as well as Wake-on-LAN using Magic Packets with or without SecureOn
> passwords.

Out of curiosity, do you have a plan to support runtime power suspend,
say through phy_driver.link_change_notify ?

-- 
Ueimor
