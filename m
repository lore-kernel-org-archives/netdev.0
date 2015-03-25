From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/7] net: bcmgenet: remove priv->int0_mask and
 priv->int1_mask
Date: Wed, 25 Mar 2015 15:20:00 -0700
Message-ID: <55133490.90708@gmail.com>
References: <20150325193509.D65552201FC@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34647 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbbCYWUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 18:20:45 -0400
Received: by pacwe9 with SMTP id we9so42584783pac.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 15:20:45 -0700 (PDT)
In-Reply-To: <20150325193509.D65552201FC@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/15 12:35, Petri Gynther wrote:
> Remove unused priv->int0_mask and priv->int1_mask.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
