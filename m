From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sch: add missing u64 in psched_ratecfg_precompute()
Date: Wed, 27 Mar 2013 08:56:17 -0700
Message-ID: <1364399777.15753.15.camel@edumazet-glaptop>
References: <10857839.dV42UeFzbk@tuxracer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "vger.kernel.org" <netdev@vger.kernel.org>
To: Sergey Popovich <popovich_sergei@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:63616 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274Ab3C0P4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 11:56:19 -0400
Received: by mail-ie0-f178.google.com with SMTP id bn7so7929432ieb.37
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 08:56:19 -0700 (PDT)
In-Reply-To: <10857839.dV42UeFzbk@tuxracer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-27 at 17:41 +0200, Sergey Popovich wrote:
> It seems that commit
> 
> commit 292f1c7ff6cc10516076ceeea45ed11833bb71c7
> Author: Jiri Pirko <jiri@resnulli.us>
> Date:   Tue Feb 12 00:12:03 2013 +0000
> 
>     sch: make htb_rate_cfg and functions around that generic
> 
> adds little regression.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks
