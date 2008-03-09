From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][AX25] ax25_out: check skb for NULL in ax25_kick()
Date: Sun, 9 Mar 2008 19:03:00 +0100
Message-ID: <20080309180300.GB3339@ami.dom.local>
References: <20080206074529.GC4496@ff.dom.local> <20080213115607.GB2867@ff.dom.local> <025801c86ea3$75add3f0$453c822c@dg8ngn> <47D3A7AF.1030607@free.fr> <20080309143052.GA2749@ami.dom.local> <001101c8820b$e0409880$453c822c@dg8ngn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Pidoux' <f6bvp@free.fr>, 'David Miller' <davem@davemloft.net>,
	'Ralf Baechle' <ralf@linux-mips.org>, netdev@vger.kernel.org
To: Jann Traschewski <jann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:19118 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbYCIR5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2008 13:57:53 -0400
Received: by fg-out-1718.google.com with SMTP id e21so1608303fga.17
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2008 10:57:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <001101c8820b$e0409880$453c822c@dg8ngn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 09, 2008 at 06:34:47PM +0100, Jann Traschewski wrote:
> Indeed. I'd like to see it in 2.6.24. My heavy used machine has no problems
> with this patch since 13 days now.

I hope David or Ralf will consider this.

BTW, Jann, I guess we're waiting with this last AX.25 testing patch
for the magic 13 too?

Thanks,
Jarek P.
