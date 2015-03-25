From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: fix ipv4 mapped request socks
Date: Tue, 24 Mar 2015 22:21:02 -0700
Message-ID: <1427260862.25985.105.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427258756.25985.104.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150325.005738.199321600853824869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:36088 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbbCYFVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 01:21:04 -0400
Received: by igbud6 with SMTP id ud6so92049437igb.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 22:21:03 -0700 (PDT)
In-Reply-To: <20150325.005738.199321600853824869.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-25 at 00:57 -0400, David Miller wrote:

> Applied, thanks Eric.
> 
> Please put the Fixes: tag before all the signoffs and acks
> in the future, thanks in advance.

Sure, I will try to remember this rule ;)
