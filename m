From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp:elapsed variable calculated twice while
 keepalive working
Date: Tue, 06 Aug 2013 05:23:12 -0700
Message-ID: <1375791792.4457.99.camel@edumazet-glaptop>
References: <1375790724-18834-1-git-send-email-tingw.liu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net
To: Tingwei Liu <tingw.liu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:58240 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755449Ab3HFMXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 08:23:13 -0400
Received: by mail-pb0-f44.google.com with SMTP id xa7so341968pbc.31
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 05:23:13 -0700 (PDT)
In-Reply-To: <1375790724-18834-1-git-send-email-tingw.liu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 20:05 +0800, Tingwei Liu wrote:
> ---
>  net/ipv4/tcp_timer.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)

I suggest reading Documentation/SubmittingPatches, because you forgot
the "Signed-off-by:" tag, and you did the same on your last patch
submission.
