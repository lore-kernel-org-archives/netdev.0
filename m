From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [PATCH] Fix comment for packets without data
Date: Fri, 14 Dec 2012 11:56:11 +0100
Message-ID: <50CB05CB.8020406@enst-bretagne.fr>
References: <1355423248-12448-1-git-send-email-florent.fourcot@enst-bretagne.fr> <50CA23AA.1040501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:42358 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab2LNLBw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 06:01:52 -0500
In-Reply-To: <50CA23AA.1040501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> Perhaps "(protoff == skb->len) means the packet has no
> data, just IPv6 and extension headers, but it is tracked anyway."
> 

I agree, and I send a new patch. But I was not sure if I should add you
in "Signed-off-by" list.

Regards,

-- 
Florent.
