From: Jeremy Kerr <jk@ozlabs.org>
Subject: Re: [PATCH] sctp: rfc conformance fixes
Date: Thu, 23 Oct 2008 16:54:57 +1100
Message-ID: <200810231654.58155.jk@ozlabs.org>
References: <48FFBA06.50609@hp.com> <20081022.211148.98722383.davem@davemloft.net> <1224740852.7654.390.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org, mbizon@freebox.fr, patchwork@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60969 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086AbYJWFzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2008 01:55:43 -0400
In-Reply-To: <1224740852.7654.390.camel@pasglop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben,

> If we keep an archive of the list, we can use patchwork hashing
> feature to basically generate hashes for all patches in the archive
> over the last N month, and then use the patchwork client interface to
> check if they are all indeed referenced there. If not, we can then
> re-inject them.

Simpler way - I just get the patchwork parser to store any mail that it 
rejects.

It's next on the patchwork todo list.

Cheers,


Jeremy
