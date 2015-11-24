From: Florian Westphal <fw@strlen.de>
Subject: Re: Increasing skb->mark size
Date: Tue, 24 Nov 2015 21:36:02 +0100
Message-ID: <20151124203602.GB23215@breakpoint.cc>
References: <1448397144.14854.27.camel@mattb-dl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>
To: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59913 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754641AbbKXUgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 15:36:06 -0500
Content-Disposition: inline
In-Reply-To: <1448397144.14854.27.camel@mattb-dl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Bennett <Matt.Bennett@alliedtelesis.co.nz> wrote:
> I'm emailing this list for feedback on the feasibility of increasing
> skb->mark or adding a new field for marking. Perhaps this extension
> could be done under a new CONFIG option. Perhaps there are other ways we
> could achieve the desired behaviour?

Well I pointed you towards connlabels which provide 128 bit of space
in the conntrack extension area but you did not tell me why you cannot
use it.
