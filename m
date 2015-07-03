From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Searching for mentor - writing kernel-space VPN & more
Date: Fri, 3 Jul 2015 02:46:38 +0200
Message-ID: <CAHmME9okP0hQtGqOy_xp5cC_Q5nDd4qo2GibykLXhFJzkMCHOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:42155 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753273AbbGCAql (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2015 20:46:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'm working on a fairly advanced kernel space VPN with some
interesting design choices. It's requiring me to dig pretty deep into
the networking stack. Admittedly I'm a bit in over my head right now.
Does anyone with deep knowledge and experience, especially inside the
networking stack, have any interest in mentoring me through this and
other kernel-related development puzzles?

As I understand it, Linux is in need of more developers, and I think
with a good mentor I could go pretty far, and eventually join the
ranks of someone useful to others.

What I mean specifically is someone I can poke on instant message from
time to time, "hey should I be using skb_dequeue or skb_recv_datagram
here?" or "do I want to pop this in the work queue or keep it in
softirq?" or "do I need to rcu_deref the qdisc?" or a variety of other
intricate questions and considerations. I'm a pretty quick learner and
quite devoted, but not all of this is documented and my eyeballs are
starting to bleed from reading too many innards; having someone I can
actually talk to and mind-meld with would be extremely nice.

In case bragging about something makes this a more attractive
proposition: I just got avx and avx2 implementations of
chacha20poly1305 rolling successfully, which I'm quite proud of.

Well, hope to hear from somebody soon!

Regards,
Jason Donenfeld
