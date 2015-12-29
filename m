From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net, socket, socket_wq: fix missing initialization
 of flags
Date: Tue, 29 Dec 2015 14:03:19 -0500
Message-ID: <1451415799.8255.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87ege73bma.fsf@gmail.com>
	 <1451323186.8255.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87ziwtphdo.fsf_-_@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicolai Stange <nicstange@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36537 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753606AbbL2TDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 14:03:22 -0500
In-Reply-To: <87ziwtphdo.fsf_-_@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-29 at 13:29 +0100, Nicolai Stange wrote:
> Fixes: ceb5d58b2170 ("net: fix sock_wake_async() rcu protection")

>  Sorry for any inconvenience this late-night induced brainfart might
>  have caused at your side...

Not really, because I read the source code and saw the bug there ;)

Acked-by: Eric Dumazet <edumazet@google.com>
