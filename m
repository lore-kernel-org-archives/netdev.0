From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH] net: Fix recvmmsg timeout handling
Date: Mon, 21 Jul 2014 16:43:42 -0300
Message-ID: <20140721194342.GB20303@kernel.org>
References: <20140721192131.GA3212@kernel.org>
 <2420976.9PK0ZQpOTD@basile.remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.19.201]:39602 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755268AbaGUTns (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2014 15:43:48 -0400
Content-Disposition: inline
In-Reply-To: <2420976.9PK0ZQpOTD@basile.remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Jul 21, 2014 at 10:26:45PM +0300, R=E9mi Denis-Courmont escreve=
u:
> FWIW, fine by me.

Ok, and it is worth something, yes, can we make it a:

Acked-by: R=E9mi Denis-Courmont <remi@remlab.net>

That is the way to have what you just said registered in the patch
itself, ok?

If so, David, can you slap that there, please?

- Arnaldo
