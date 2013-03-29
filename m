From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net] net: fq_codel: Fix off-by-one error
Date: Fri, 29 Mar 2013 14:49:34 -0700
Message-ID: <CAGK4HS_MQDzQZpTv6RXj--Sxyx8DcnP0Zk2PHxoiDLvHE9rW0A@mail.gmail.com>
References: <1364514720-20780-1-git-send-email-subramanian.vijay@gmail.com>
	<1364569280.5113.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:46905 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756936Ab3C2Vtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 17:49:35 -0400
Received: by mail-ob0-f176.google.com with SMTP id er7so649479obc.21
        for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 14:49:35 -0700 (PDT)
In-Reply-To: <1364569280.5113.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Just curious, did you play changing the default limit (10240 packets) ?
>
>

Eric,
So far we have not changed the default but we are planning to run some
more tests next week with fq_codel.
We can try different values for limit. If you have any other
suggestions for testing, please let me know.

Thanks!
Vijay
