From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 4/4] net: dsa: Move ports assignment closer to
 error checking
Date: Wed, 6 Jul 2016 14:50:11 +0300
Message-ID: <ec93aa44-c66e-7a7e-beee-d259e8c15037@cogentembedded.com>
References: <1467756433-25062-1-git-send-email-f.fainelli@gmail.com>
 <1467756433-25062-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:35538 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbcGFLzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 07:55:38 -0400
Received: by mail-lf0-f53.google.com with SMTP id l188so152868537lfe.2
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 04:55:37 -0700 (PDT)
In-Reply-To: <1467756433-25062-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 7/6/2016 1:07 AM, Florian Fainelli wrote:

> Move the assignment of ports in _dsa_register_switch() closer to where
> it is checked, no functional change. Re-order declarations to be

    "Be" doesn't seem needed here.

> preserve the inverted christmas tree style.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

[...]

MBR, Sergei
