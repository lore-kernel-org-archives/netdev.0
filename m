From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next v3 0/3] net: core: Two Helper function about
 socket information
Date: Thu, 23 Feb 2017 12:00:46 -0500
Message-ID: <CAF=yD-+LV_4_7BpYmMyv=XZtbvikZ1nyp3eOExrrtjcP_PUnVg@mail.gmail.com>
References: <1487824932-5105-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:35340 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751107AbdBWRIe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 12:08:34 -0500
Received: by mail-wr0-f182.google.com with SMTP id s27so25806645wrb.2
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 09:07:35 -0800 (PST)
In-Reply-To: <1487824932-5105-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2017 at 11:42 PM, Chenbo Feng
<chenbofeng.kernel@gmail.com> wrote:
> From: Chenbo Feng <fengc@google.com>
>
> Introduce two eBpf helper function to get the socket cookie and
> socket uid for each packet. The helper function is useful when
> the *sk field inside sk_buff is not empty. These helper functions
> can be used on socket and uid based traffic monitoring programs.

Net-next is closed. But we can review as RFC.
