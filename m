From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 6/7] net: bcmgenet: rework Rx NAPI code
Date: Wed, 25 Mar 2015 15:27:51 -0700
Message-ID: <55133667.4020206@gmail.com>
References: <20150325193515.354C12201FB@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35874 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbbCYW2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 18:28:35 -0400
Received: by pdbcz9 with SMTP id cz9so42104631pdb.3
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 15:28:34 -0700 (PDT)
In-Reply-To: <20150325193515.354C12201FB@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/15 12:35, Petri Gynther wrote:
> Introduce new bcmgenet functions to handle the NAPI calls to:
> netif_napi_add()
> napi_enable()
> napi_disable()
> netif_napi_del()
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
