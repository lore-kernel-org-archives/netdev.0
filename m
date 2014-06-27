From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] udp: Add MIB counters for rcvbuferrors
Date: Thu, 26 Jun 2014 21:29:52 -0700
Message-ID: <1403843392.15139.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1403732293-32304-1-git-send-email-james.leddy@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James M Leddy <james.leddy@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:52195 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbaF0E34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 00:29:56 -0400
Received: by mail-wg0-f50.google.com with SMTP id m15so4612719wgh.9
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 21:29:55 -0700 (PDT)
In-Reply-To: <1403732293-32304-1-git-send-email-james.leddy@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-06-25 at 17:38 -0400, James M Leddy wrote:
> Add MIB counters for rcvbuferrors in UDP to help diagnose problems.
> 
> Signed-off-by: James M Leddy <james.leddy@redhat.com>
> ---
>  net/ipv4/udp.c |    5 ++++-
>  net/ipv6/udp.c |    6 +++++-
>  2 files changed, 9 insertions(+), 2 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
