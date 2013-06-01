From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH v3 1/3] net: ipv6: Unify {raw,udp}6_sock_seq_show.
Date: Sat, 1 Jun 2013 10:00:38 +0900
Message-ID: <CAKD1Yr0Qz9NKJ_2MYU5Rh2xFaAwnHZT4d4tww-a6Sk23gMik1w@mail.gmail.com>
References: <ko3rsc@ger.gmane.org> <1369806459-26901-1-git-send-email-lorenzo@google.com>
 <1369806459-26901-2-git-send-email-lorenzo@google.com> <20130531.170113.626875599168962007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f48.google.com ([209.85.128.48]:48026 "EHLO
	mail-qe0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092Ab3FABBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 21:01:00 -0400
Received: by mail-qe0-f48.google.com with SMTP id 9so126787qea.21
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 18:00:59 -0700 (PDT)
In-Reply-To: <20130531.170113.626875599168962007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 1, 2013 at 9:01 AM, David Miller <davem@davemloft.net> wrote:
> Do not mix functional changes with unrelated whitespace and other cleanups.
>
> Split this patch series up properly and resubmit this entire series.

Ok, new patch series coming up.
