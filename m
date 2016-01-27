From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: bcmgenet.h: fix 0x0x prefix
Date: Wed, 27 Jan 2016 10:27:49 -0800
Message-ID: <56A90C25.1010306@gmail.com>
References: <1453902852-32649-1-git-send-email-ao2@ao2.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Antonio Ospite <ao2@ao2.it>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34949 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934573AbcA0S2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 13:28:44 -0500
Received: by mail-pf0-f173.google.com with SMTP id 65so8766968pfd.2
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 10:28:44 -0800 (PST)
In-Reply-To: <1453902852-32649-1-git-send-email-ao2@ao2.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/01/16 05:54, Antonio Ospite wrote:
> Fix the 0x0x prefix in an integer constant.
> 
> In this case, while at it, also fix a typo (s/unitcast/unicast/).
> 
> Signed-off-by: Antonio Ospite <ao2@ao2.it>
> Cc: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
