From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: Testing server performance
Date: Mon, 12 Dec 2011 10:45:39 +0100
Message-ID: <CAFdo_mVhSHz0zhX4o7jxxCVrim7cw4vB3S70eddfbPWVXRYv_Q@mail.gmail.com>
References: <CAFdo_mW0sKSZp3L75BOPBN1Sa+ZQ8WiBRC98eFLM5BaxCVrpJQ@mail.gmail.com>
	<1323682612.2948.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:38581 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752116Ab1LLJpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Dec 2011 04:45:44 -0500
Received: from localhost (avs2.etf.rs [147.91.14.173])
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id 89AA360139
	for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 10:45:42 +0100 (CET)
Received: from mx2.etf.bg.ac.rs ([147.91.14.170])
	by localhost (avs2.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id MLycA8KX5vaP for <netdev@vger.kernel.org>;
	Mon, 12 Dec 2011 10:45:41 +0100 (CET)
Received: from mail-gx0-f174.google.com (mail-gx0-f174.google.com [209.85.161.174])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id 4E97C60137
	for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 10:45:41 +0100 (CET)
Received: by ggdk6 with SMTP id k6so849167ggd.19
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 01:45:39 -0800 (PST)
In-Reply-To: <1323682612.2948.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I have doubts you get such poor performance from your machine.
>
> 77Mbps, thats how many packets per second ???
>

I've got 77MBps not 77Mbps. :)
I was testing with packets of length 1024B
That's about 80000 packets/s
