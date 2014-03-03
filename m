From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2] net: fix for a race condition in the inet frag code
Date: Mon, 3 Mar 2014 23:21:18 +0100
Message-ID: <20140303222118.GJ9965@breakpoint.cc>
References: <1393855520-18334-1-git-send-email-nikolay@redhat.com>
 <1393885158-4116-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:53501 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755001AbaCCWVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 17:21:20 -0500
Content-Disposition: inline
In-Reply-To: <1393885158-4116-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> v2: Add more information on the flow leading to the race and an example.
> I hope this is better :-)

It is, thanks Nik!
