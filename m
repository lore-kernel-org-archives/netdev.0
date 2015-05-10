From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 0/2] handle_ing update
Date: Sun, 10 May 2015 20:06:43 +0200
Message-ID: <20150510180643.GA3862@salvia>
References: <cover.1431203900.git.daniel@iogearbox.net>
 <20150510170550.GA4442@salvia>
 <554F9B8B.30306@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45096 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751549AbbEJSCD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 14:02:03 -0400
Content-Disposition: inline
In-Reply-To: <554F9B8B.30306@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 10, 2015 at 10:55:23AM -0700, Alexei Starovoitov wrote:
> you're doing exactly the same in your patch set, but with added extra
> overhead for netfilter hook.

I will *not* use that hook for Netfilter.

DOT.
