From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCHv2 net-next 0/5] pktgen IPsec support
Date: Wed, 11 Dec 2013 08:42:22 -0500
Message-ID: <52A86BBE.1090408@mojatatu.com>
References: <1386323614-5077-1-git-send-email-fan.du@windriver.com>	<20131209.195854.223825767831436997.davem@davemloft.net>	<52A66C0D.4050409@windriver.com> <20131209.202321.2134510956668375662.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:46446 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414Ab3LKNuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 08:50:11 -0500
Received: by mail-ig0-f176.google.com with SMTP id k19so3648849igc.3
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 05:50:10 -0800 (PST)
In-Reply-To: <20131209.202321.2134510956668375662.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/13 20:23, David Miller wrote:

> Maybe they didn't care about the checksum being correct in the
> testbed they were using.

Thats correct. The point is to exercise the crypto code.
Please dont change this.

cheers,
jamal
