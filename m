From: Daurnimator <quae@daurnimator.com>
Subject: Re: EINVAL when using connect() for udp sockets
Date: Wed, 29 Mar 2017 10:45:50 +1100
Message-ID: <CAEnbY+e0to_bkJd4L5fB7QZ9sswkmgK2Fr2NGZ__EhoH77foTg@mail.gmail.com>
References: <CAEnbY+cYpX8naDpRkXgwCP=i64AwWgK9=_7AacmYip-ykot7mQ@mail.gmail.com>
 <CAEnbY+fPLamzXF8nOF-SEFE8LaE88XAyKNt81zs6bM866R4oGg@mail.gmail.com>
 <1490246287.16816.201.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVVBfwd7P0-dY08Bw7QNr_w77va4AEMFj5xMuOddQoq2g@mail.gmail.com>
 <1490397560.24891.0.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUQ52aiKQntMsrm2aMQ56G=tHCpN93A0+mffss+6m39jw@mail.gmail.com>
 <1490742712.24891.25.camel@edumazet-glaptop3.roam.corp.google.com> <CAEnbY+cz6jSLrqmE53nxScF92tRNv9HE7620tpjJ28E57_dPVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        William Ahern <william@25thandclement.com>,
        "Santi T." <santitm99@gmail.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:37919 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932242AbdC1Xp7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:45:59 -0400
Received: by mail-it0-f54.google.com with SMTP id y18so39640326itc.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 16:45:57 -0700 (PDT)
Received: from mail-it0-f52.google.com (mail-it0-f52.google.com. [209.85.214.52])
        by smtp.gmail.com with ESMTPSA id r133sm2413109ith.9.2017.03.28.16.45.51
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 16:45:51 -0700 (PDT)
Received: by mail-it0-f52.google.com with SMTP id y18so39639959itc.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 16:45:51 -0700 (PDT)
In-Reply-To: <CAEnbY+cz6jSLrqmE53nxScF92tRNv9HE7620tpjJ28E57_dPVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29 March 2017 at 10:44, Daurnimator <quae@daurnimator.com> wrote:
> This should probably incorrect behaviour and should the operation
> should succeed.

Uh, not sure why there are so many "should"s in that message.

This is probably incorrect behaviour and the operation should succeed.
