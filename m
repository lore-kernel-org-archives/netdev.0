From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC PATCH net-next] net: ipv6: Add a sysctl to make optimistic
 addresses useful candidates
Date: Fri, 17 Oct 2014 17:31:43 +0900
Message-ID: <CAKD1Yr0eUSmDAoU4fNrW17v1gq2srKQtxRnq_8Stt5LiGwNnbw@mail.gmail.com>
References: <1413520309-13814-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:45539 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbaJQIcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 04:32:06 -0400
Received: by mail-ie0-f178.google.com with SMTP id rl12so305544iec.9
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 01:32:04 -0700 (PDT)
In-Reply-To: <1413520309-13814-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 17, 2014 at 1:31 PM, Erik Kline <ek@google.com> wrote:
> Add a sysctl that causes an interface's optimistic addresses
> to be considered equivalent to other non-deprecated addresses
> for source address selection purposes.  Preferred addresses
> will still take precendence over optimistic addresses, subject
> to other ranking in the source address selection algorithm.
> [...]
> Signed-off-by: Erik Kline <ek@google.com>

Acked-by: Lorenzo Colitti <lorenzo@google.com>
