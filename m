From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next 1/3] net: add inet_sk_transparent() helper
Date: Tue, 22 Dec 2015 14:04:43 -0500
Message-ID: <1450811083.8474.133.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1450729766-14926-1-git-send-email-fw@strlen.de>
	 <1450729766-14926-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:34553 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933201AbbLVTEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 14:04:46 -0500
Received: by mail-qg0-f47.google.com with SMTP id 74so70118746qgh.1
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 11:04:45 -0800 (PST)
In-Reply-To: <1450729766-14926-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-12-21 at 21:29 +0100, Florian Westphal wrote:
> Avoids cluttering tcp_v4_send_reset when followup patch extends
> it to deal with timewait sockets.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
