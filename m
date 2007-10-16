From: jamal <hadi@cyberus.ca>
Subject: [PATCHES] cleanup skb_clone
Date: Tue, 16 Oct 2007 08:22:24 -0400
Message-ID: <1192537344.4480.71.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:52762 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbXJPMWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 08:22:52 -0400
Received: by wa-out-1112.google.com with SMTP id v27so2359908wah
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 05:22:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am going to send three patches:
1) Introduces skb_act_clone
2) Uses skb_act_clone
3) documents expect behavior of actions in case of cloning or copying
skbs.

cheers,
jamal

