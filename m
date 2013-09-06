From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bnx2x: fix broken compilation with
 CONFIG_BNX2X_SRIOV is not set
Date: Fri, 06 Sep 2013 09:10:48 -0700
Message-ID: <1378483848.31445.29.camel@edumazet-glaptop>
References: <1378452928-6072-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Ariel Elior <ariele@broadcom.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:38943 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753581Ab3IFQKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 12:10:50 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf1so3551301pab.10
        for <netdev@vger.kernel.org>; Fri, 06 Sep 2013 09:10:49 -0700 (PDT)
In-Reply-To: <1378452928-6072-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-06 at 10:35 +0300, Dmitry Kravkov wrote:
> Since commit 60cad4e67bd6ff400e7ea61fe762b3042b12ae9d
> "bnx2x: VF RSS support - VF side" fails to compile w/o
> CONFIG_BNX2X_SRIOV option.
>  
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> ---

Thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
