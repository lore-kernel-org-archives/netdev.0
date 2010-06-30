From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] act_nat: use stack variable
Date: Wed, 30 Jun 2010 06:25:21 -0400
Message-ID: <1277893521.3509.17.camel@bigi>
References: <1277888829-30230-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51081 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202Ab0F3KZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 06:25:24 -0400
Received: by vws5 with SMTP id 5so802828vws.19
        for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 03:25:24 -0700 (PDT)
In-Reply-To: <1277888829-30230-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-30 at 17:07 +0800, Changli Gao wrote:
> act_nat: use stack variable
> 
> structure tc_nat isn't too big for stack, so we can put it in stack.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Doesnt look unreasonable - will let Herbert make the call..

cheers,
jamal

