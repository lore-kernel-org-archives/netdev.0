From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH] pkt_sched: fq: clear time_next_packet for reused flows
Date: Mon, 28 Oct 2013 00:02:47 -0700
Message-ID: <CAGK4HS-r__7Sxj6ZFm=XhBrXM8YYzeoVi4Kc9oG6O5RLOGXggw@mail.gmail.com>
References: <1382612508.7572.53.camel@edumazet-glaptop.roam.corp.google.com>
	<CAGK4HS945jCtfOoa_ENhTwZQvnSRJpHdWVDyhF+wjE56bjT8Pw@mail.gmail.com>
	<1382916945.4045.22.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f178.google.com ([209.85.128.178]:38275 "EHLO
	mail-ve0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811Ab3J1HCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 03:02:49 -0400
Received: by mail-ve0-f178.google.com with SMTP id jy13so5519710veb.23
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 00:02:48 -0700 (PDT)
In-Reply-To: <1382916945.4045.22.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>
> What exact RB corruptions do you see ?
>
> RB trees allow items with the same key.
>
Thanks for the clarification. I incorrectly thought duplicates are not allowed.
Sorry for the noise.

Vijay
