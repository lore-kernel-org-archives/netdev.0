From: Daurnimator <quae@daurnimator.com>
Subject: Re: EINVAL when using connect() for udp sockets
Date: Fri, 28 Apr 2017 12:55:56 +1000
Message-ID: <CAEnbY+cu_b1NddDcKMumK2npmxh4yh4kEoeeY1db2Ct3JntG9g@mail.gmail.com>
References: <CAEnbY+cYpX8naDpRkXgwCP=i64AwWgK9=_7AacmYip-ykot7mQ@mail.gmail.com>
 <CAEnbY+fPLamzXF8nOF-SEFE8LaE88XAyKNt81zs6bM866R4oGg@mail.gmail.com>
 <1490246287.16816.201.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVVBfwd7P0-dY08Bw7QNr_w77va4AEMFj5xMuOddQoq2g@mail.gmail.com>
 <1490397560.24891.0.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUQ52aiKQntMsrm2aMQ56G=tHCpN93A0+mffss+6m39jw@mail.gmail.com>
 <1490742712.24891.25.camel@edumazet-glaptop3.roam.corp.google.com>
 <1490748756.24891.27.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpWyQJ+XN_4mSarzHRYX4eio81G49i=wyE5MHS+AUFWU8g@mail.gmail.com>
 <1490918579.24891.82.camel@edumazet-glaptop3.roam.corp.google.com> <CAM_iQpXmx1GN3zvnuB6SAp9fBo_yf8G3nubGeec6tMYs4BTt2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        William Ahern <william@25thandclement.com>,
        "Santi T." <santitm99@gmail.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35975 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939500AbdD1C4A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 22:56:00 -0400
Received: by mail-io0-f180.google.com with SMTP id p80so45818540iop.3
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 19:55:59 -0700 (PDT)
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com. [209.85.223.169])
        by smtp.gmail.com with ESMTPSA id t69sm1914157ioi.54.2017.04.27.19.55.57
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 19:55:58 -0700 (PDT)
Received: by mail-io0-f169.google.com with SMTP id k87so46036652ioi.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 19:55:57 -0700 (PDT)
In-Reply-To: <CAM_iQpXmx1GN3zvnuB6SAp9fBo_yf8G3nubGeec6tMYs4BTt2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 April 2017 at 03:52, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Please submit your patch formally and with a man page patch too.

Did a patch get submitted? I had a look but couldn't see it.
