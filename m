From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/6] net: bcmgenet: checkpatch fixes
Date: Tue, 22 Jul 2014 10:57:19 -0700
Message-ID: <CAGVrzca_mP6H7YbtHNTLE3yjTUHSEcRPrCz9We1Qs6V5NgNSJQ@mail.gmail.com>
References: <1406051718-15883-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:53686 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaGVR6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 13:58:00 -0400
Received: by mail-oi0-f48.google.com with SMTP id h136so2897oig.35
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 10:57:59 -0700 (PDT)
In-Reply-To: <1406051718-15883-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-07-22 10:55 GMT-07:00 Florian Fainelli <f.fainelli@gmail.com>:
> Hi David,
>
> This patch series contains cleanups for CHECK and WARNINGS reported by
> checkpatch.pl.

Whoops, there's a build failure introduced by one the changes, I will
resubmit shortly, sorry about that.

>
> Thanks!
>
> Florian Fainelli (6):
>   net: bcmgenet: remove FSF mail address
>   net: bcmgenet: add missing blank line after declaration
>   net: bcmgenet: re-align multiple lines correctly
>   net: bcmgenet: add and remove missing blank lines
>   net: bcmgenet: add missing braces to some if statements
>   net: bcmgenet: use kcalloc instead of kzalloc
>
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 283 ++++++++++++-------------
>  drivers/net/ethernet/broadcom/genet/bcmgenet.h |  20 +-
>  drivers/net/ethernet/broadcom/genet/bcmmii.c   |  39 ++--
>  3 files changed, 155 insertions(+), 187 deletions(-)
>
> --
> 1.9.1
>



-- 
Florian
