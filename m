From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] net/sched: act_skbmod: remove unneeded rcu_read_unlock in
 tcf_skbmod_dump
Date: Sat, 4 Mar 2017 21:21:38 -0500
Message-ID: <019dfc93-b1b4-a8ce-f04d-e971d352205b@mojatatu.com>
References: <1488672115-11057-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36083 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752391AbdCECVl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Mar 2017 21:21:41 -0500
Received: by mail-io0-f194.google.com with SMTP id 68so11734150ioh.3
        for <netdev@vger.kernel.org>; Sat, 04 Mar 2017 18:21:40 -0800 (PST)
In-Reply-To: <1488672115-11057-1-git-send-email-khoroshilov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-03-04 07:01 PM, Alexey Khoroshilov wrote:
> Found by Linux Driver Verification project (linuxtesting.org).
>
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
