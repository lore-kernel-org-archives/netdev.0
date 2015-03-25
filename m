From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/7] net: bcmgenet: modify Tx ring int_enable
 and int_disable vectors
Date: Wed, 25 Mar 2015 15:22:00 -0700
Message-ID: <55133508.5000508@gmail.com>
References: <20150325193510.E280D2201FB@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34871 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbbCYWWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 18:22:43 -0400
Received: by pagj7 with SMTP id j7so42714752pag.2
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 15:22:43 -0700 (PDT)
In-Reply-To: <20150325193510.E280D2201FB@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/15 12:35, Petri Gynther wrote:
> Remove unnecessary function parameter priv. Use ring->priv instead.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
