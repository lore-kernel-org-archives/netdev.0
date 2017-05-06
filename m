From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net] bnxt_en: allocate enough space for ->ntp_fltr_bmap
Date: Fri, 5 May 2017 18:04:48 -0700
Message-ID: <CACKFLin+_b2wVk_8Jvy7znR4Ny8QqOwz=A=wE8BvtZ-47FmUNA@mail.gmail.com>
References: <20170506004901.ruf3g47szijai4yk@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:33427 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750811AbdEFBEv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 21:04:51 -0400
Received: by mail-lf0-f46.google.com with SMTP id r17so11371471lfg.0
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 18:04:50 -0700 (PDT)
In-Reply-To: <20170506004901.ruf3g47szijai4yk@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 5, 2017 at 5:49 PM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> We have the number of longs, but we need to calculate the number of
> bytes required.
>
> Fixes: c0c050c58d84 ("bnxt_en: New Broadcom ethernet driver.")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Michael Chan <michael.chan@broadcom.com>

David, please send this to -stable as well.  Thanks.
