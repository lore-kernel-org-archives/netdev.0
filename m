From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next] tcp: Remove some spurious dropped packet profile
 hits from the passive connection accept path
Date: Thu, 20 Nov 2014 12:15:44 -0800
Message-ID: <CAGK4HS--0es1kYYNn-Vgy+RR2U9=Ci8KWjR9WUhf5jkW1Q3Aog@mail.gmail.com>
References: <20141120185829.986CB290095D@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Rick Jones <raj@tardy.usa.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:49610 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757979AbaKTUPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 15:15:45 -0500
Received: by mail-wg0-f50.google.com with SMTP id k14so4680319wgh.23
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 12:15:44 -0800 (PST)
In-Reply-To: <20141120185829.986CB290095D@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +                        * 99 times out of 10, there won't actually be any

Minor typo here..    s/10/100.

Vijay
