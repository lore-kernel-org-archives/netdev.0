From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] netfilter: remove dead code
Date: Wed, 30 Sep 2015 02:45:07 +0200
Message-ID: <20150930004507.GH19923@breakpoint.cc>
References: <1443572700-29705-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42516 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751943AbbI3ApK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 20:45:10 -0400
Content-Disposition: inline
In-Reply-To: <1443572700-29705-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flavio Leitner <fbl@redhat.com> wrote:
> Remove __nf_conntrack_find() from headers.
> Fixes: dcd93ed4cd1 ("netfilter: nf_conntrack: remove dead code"

For the record: netfilter patches should go to
netfilter-devel@vger.kernel.org .

That being said, in this case I doubt Pablo minds if David takes this
directly, patch ts obviously correct[tm] :)
