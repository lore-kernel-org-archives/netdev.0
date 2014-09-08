From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next] net_sched: sfq: remove unused macro
Date: Mon, 08 Sep 2014 14:59:46 -0700
Message-ID: <1410213586.11872.134.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410211981-31081-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:63579 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724AbaIHV7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 17:59:47 -0400
Received: by mail-pd0-f171.google.com with SMTP id p10so4627811pdj.16
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 14:59:47 -0700 (PDT)
In-Reply-To: <1410211981-31081-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-08 at 23:33 +0200, Florian Westphal wrote:
> not used anymore since ddecf0f
> (net_sched: sfq: add optional RED on top of SFQ).

SGTM ;)

Acked-by: Eric Dumazet <edumazet@google.com>
