From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH 01/28] bnxt_en: Add bnxt_set_max_func_irqs().
Date: Mon, 5 Dec 2016 09:10:40 -0800
Message-ID: <CACKFLi=i31Mgbry6zgqWYGNBgEsDRZthRGyoSLyHKJkhNN2KAg@mail.gmail.com>
References: <1480919912-1079-1-git-send-email-selvin.xavier@broadcom.com>
 <1480919912-1079-2-git-send-email-selvin.xavier@broadcom.com> <20161205.114704.1700305660817315475.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Selvin Xavier <selvin.xavier@broadcom.com>, dledford@redhat.com,
        linux-rdma@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:33915 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751913AbcLERKm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 12:10:42 -0500
Received: by mail-oi0-f51.google.com with SMTP id y198so347941191oia.1
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 09:10:41 -0800 (PST)
In-Reply-To: <20161205.114704.1700305660817315475.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 5, 2016 at 8:47 AM, David Miller <davem@davemloft.net> wrote:
>
> It really doesn't make any sense to only send 7 out of 28 of these
> patches to the networking list.
>
> In fact I would say that you need to split this series into two
> components.

OK.  I will resend those bnxt_en patches later today as a separate series.

>
> One that goes into the networking tree, and once that's accepted you
> can submit the IB parts to that subsystem's maintainer.
