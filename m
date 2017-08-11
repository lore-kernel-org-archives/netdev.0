From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] net: skb_needs_check() removes
 CHECKSUM_UNNECESSARY check for tx.
Date: Fri, 11 Aug 2017 10:43:24 -0700
Message-ID: <CAF=yD-KxGPO2CB50seuZ8p_4ymTkfi9=GWjsLYDuO-KWi0jwUw@mail.gmail.com>
References: <1502421389-20152-1-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:38549 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752989AbdHKRoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 13:44:05 -0400
Received: by mail-oi0-f65.google.com with SMTP id s21so3932151oie.5
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 10:44:05 -0700 (PDT)
In-Reply-To: <1502421389-20152-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 10, 2017 at 8:16 PM, Tonghao Zhang <xiangxia.m.yue@gmail.com> wrote:
> Because we remove the UFO support, we will also remove the
> CHECKSUM_UNNECESSARY check in skb_needs_check().
>
> Cc: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>

Acked-by: Willem de Bruijn <willemb@google.com>

Thanks for fixing up and resubmitting after the merge.
