From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC v3 8/8] xdp: Cleanup after API changes
Date: Tue, 21 Feb 2017 13:24:43 -0800
Message-ID: <CALx6S372n+CNi7Pis-Z-2gGzOOPDOreLcdJVyX+AMDonRnJr5g@mail.gmail.com>
References: <20170221193417.3641224-1-tom@herbertland.com> <20170221193417.3641224-9-tom@herbertland.com>
 <20170221.160618.716814569978889472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:34453 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752980AbdBUVYu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 16:24:50 -0500
Received: by mail-qt0-f175.google.com with SMTP id n21so55409368qta.1
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 13:24:49 -0800 (PST)
In-Reply-To: <20170221.160618.716814569978889472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 1:06 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Tue, 21 Feb 2017 11:34:17 -0800
>
>>   - Change trace_xdp_hook_exception to trace_xdp_exception
>
> Just give it this final name in patch #1 where you introduce it.

That will break compilation of the intervening patches. That is okay?
