From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: better IFF_XMIT_DST_RELEASE support
Date: Sun, 05 Oct 2014 17:26:12 -0700
Message-ID: <1412555172.11091.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412267647.22242.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141004.202900.1107815015981261576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:38682 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbaJFA0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 20:26:15 -0400
Received: by mail-pd0-f169.google.com with SMTP id w10so2422800pde.0
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 17:26:14 -0700 (PDT)
In-Reply-To: <20141004.202900.1107815015981261576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-10-04 at 20:29 -0400, David Miller wrote:

> I assume you are going to rework this to use a counter indication
> in order to deal with the packet scheduler issues Julian brought
> up.

Absolutely, I will provide a v2.
