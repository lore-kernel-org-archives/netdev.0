From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: http://bugzilla.kernel.org/show_bug.cgi?id=6197
Date: Wed, 14 Jun 2006 01:38:18 +0400
Message-ID: <448F304A.2020808@tls.msk.ru>
References: <20060611055132.2930b95f.akpm@osdl.org> <448EE065.9060207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:45399 "EHLO hobbit.corpit.ru")
	by vger.kernel.org with ESMTP id S932327AbWFMViX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 17:38:23 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <448EE065.9060207@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
[]
> He patched his kernel with the IMQ device, which is known to cause all
> kinds of weird problems.

Wich problems?  Known to whom?

I was considering using imq for our needs (not done yet), and from the
FAQ at http://www.linuximq.net/faq.html (item #3, "Is it stable?") it
seems there's no problems except of gre tunnels and locally generated
traffic...

Googling for "imq linux problem" shows usual pile of various user
support questions (how to configure.. what did I do wrong.. etc),
but nothing relevant.

So... I'm curious whenever the claim on linuximq.net site about the
stability is true, or there in fact are some real issue...

Thanks.

/mjt
