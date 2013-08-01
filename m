From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: add SNMP counters tracking incoming ECN
 bits
Date: Thu, 01 Aug 2013 10:22:55 -0700
Message-ID: <1375377775.10515.174.camel@edumazet-glaptop>
References: <1375370791.10515.154.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:61658 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471Ab3HARW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 13:22:57 -0400
Received: by mail-pb0-f50.google.com with SMTP id uo5so2317224pbc.23
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 10:22:56 -0700 (PDT)
In-Reply-To: <1375370791.10515.154.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-01 at 08:26 -0700, Eric Dumazet wrote:

> Ip[6]CEPkts    : Number of packets received with Congestion Experimented

The right wording being "Congestion Experienced" , or "Congestion
Encountered"

;)
