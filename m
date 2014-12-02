From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 net-next] net: bcmgenet: enable driver to work without
 a device tree
Date: Mon, 1 Dec 2014 23:24:51 -0800
Message-ID: <CAGVrzca+T5=6ssero4yQ8z5o10mujqG_M1vZHFADkVo44pD5tw@mail.gmail.com>
References: <20141202001808.9B0E6220728@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:41696 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbaLBHZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 02:25:32 -0500
Received: by mail-ie0-f176.google.com with SMTP id tr6so11240405ieb.35
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 23:25:31 -0800 (PST)
In-Reply-To: <20141202001808.9B0E6220728@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-12-01 16:18 GMT-08:00 Petri Gynther <pgynther@google.com>:
> Modify bcmgenet driver so that it can be used on Broadcom 7xxx
> MIPS-based STB platforms without a device tree.

Have not seen any regressions with DT-only platforms, thanks!

>
> Signed-off-by: Petri Gynther <pgynther@google.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--
Florian
