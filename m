From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [RFC][PATCH] QoS TBF and latency configuration misbehavior
Date: Wed, 1 Sep 2010 12:40:50 +0400
Message-ID: <20100901084050.GA607@ms2.inr.ac.ru>
References: <AANLkTik4Mrzjfk_-u7Qg-B9Q-4tn_seqkkgmwnqQ8FOq@mail.gmail.com> <20100831210101.3c059a91@leibniz> <4C7D5EBD.103@gmail.com> <AANLkTikMJ2rtSNsBeaVTsVtw1ZmKpLjjyeYL=c+AgoFZ@mail.gmail.com> <20100831214808.GA32141@ms2.inr.ac.ru> <20100831223402.GA7101@ms2.inr.ac.ru> <20100901063602.GA6285@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Kruchinin <dkruchinin@acm.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:35157 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751269Ab0IAIk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 04:40:57 -0400
Content-Disposition: inline
In-Reply-To: <20100901063602.GA6285@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> Btw, there could be considered adding a new, alternative parameter, for
> this, like rlatency etc. if it's so crucial.

Not bad idea. I like it.

Alexey
