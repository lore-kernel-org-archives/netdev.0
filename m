From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next 1/3] net: add inet_sk_transparent() helper
Date: Tue, 22 Dec 2015 22:46:18 +0100
Message-ID: <5679C4AA.8000009@stressinduktion.org>
References: <1450729766-14926-1-git-send-email-fw@strlen.de>
 <1450729766-14926-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:58312 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933232AbbLVVqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 16:46:24 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 6D64520C9D
	for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 16:46:21 -0500 (EST)
In-Reply-To: <1450729766-14926-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.12.2015 21:29, Florian Westphal wrote:
> Avoids cluttering tcp_v4_send_reset when followup patch extends
> it to deal with timewait sockets.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
