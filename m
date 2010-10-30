From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH] af_unix: unix_write_space() use keyed wakeups
Date: Sat, 30 Oct 2010 08:03:15 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1010300759580.9195@localhost6.localdomain6>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>  <1288380431.2680.3.camel@edumazet-laptop> <1288421084.2680.717.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Rainer Weikusat <rweikusat@mssgmbh.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:49652 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836Ab0J3PDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 11:03:32 -0400
Received: from zino1
	by x35.xmailserver.org with [XMail 1.27 ESMTP Server]
	id <S360B34> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Sat, 30 Oct 2010 11:03:29 -0400
In-Reply-To: <1288421084.2680.717.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 30 Oct 2010, Eric Dumazet wrote:

> This patch is a specialization of commit 37e5540b3c9d (epoll keyed
> wakeups: make sockets use keyed wakeups).

Whoops, I must have missed AF_UNIX :)
Looks good to me.


- Davide


