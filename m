From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: simplify __bcmgenet_tx_reclaim()
Date: Fri, 27 Feb 2015 15:39:38 -0800
Message-ID: <1425080378.5130.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150225185500.C7EBC2211C6@puck.mtv.corp.google.com>
	 <54F0ED2A.9040306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:33943 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932285AbbB0Xjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 18:39:40 -0500
Received: by iecrp18 with SMTP id rp18so35071633iec.1
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 15:39:40 -0800 (PST)
In-Reply-To: <54F0ED2A.9040306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-27 at 14:18 -0800, Florian Fainelli wrote:
> On 25/02/15 10:55, Petri Gynther wrote:

> Nice cleanups!
> 
> > 
> > Signed-off-by: Petri Gynther <pgynther@google.com>
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Is any one working adding BQL & xmit_more on this driver ?
