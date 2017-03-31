From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: EINVAL when using connect() for udp sockets
Date: Fri, 31 Mar 2017 10:00:36 -0700
Message-ID: <CAM_iQpXf2xcVWSEZVgvzCpkXq+CjtQPN8E=tdxQDZ9Sy8YveQQ@mail.gmail.com>
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
Cc: Daurnimator <quae@daurnimator.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        William Ahern <william@25thandclement.com>,
        "Santi T." <santitm99@gmail.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37391 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933203AbdCaRA6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 13:00:58 -0400
Received: by mail-wm0-f48.google.com with SMTP id x124so3813254wmf.0
        for <netdev@vger.kernel.org>; Fri, 31 Mar 2017 10:00:57 -0700 (PDT)
In-Reply-To: <CAM_iQpXmx1GN3zvnuB6SAp9fBo_yf8G3nubGeec6tMYs4BTt2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 31, 2017 at 9:52 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
> Please submit your patch formally and with a man page patch too.

BTW, and probably IPv6 too.
