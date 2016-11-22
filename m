From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net: ioctl SIOCSIFADDR minor cleanup
Date: Mon, 21 Nov 2016 23:32:09 -0800
Message-ID: <CAM_iQpXVDunf5AehA1_fN7St209ZpbbJA8HEgc_wUgaf45U2hQ@mail.gmail.com>
References: <1479213899-5952-1-git-send-email-cugyly@163.com>
 <20161115.220108.1225196299725031215.davem@davemloft.net> <8729016553E3654398EA69218DA29EEF0E42F73A@cnshjmbx02>
 <20161115.223111.734917440131578613.davem@davemloft.net> <8729016553E3654398EA69218DA29EEF0E42F7ED@cnshjmbx02>
 <CAM_iQpW0SnpXfN-DjBm-72_23KxtzH8kXbbc3FiQn=VChdX3Ww@mail.gmail.com> <8729016553E3654398EA69218DA29EEF0E431D3A@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        "cugyly@163.com" <cugyly@163.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36468 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751328AbcKVHca (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 02:32:30 -0500
Received: by mail-it0-f67.google.com with SMTP id n68so777405itn.3
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 23:32:29 -0800 (PST)
In-Reply-To: <8729016553E3654398EA69218DA29EEF0E431D3A@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2016 at 8:30 PM, YUAN Linyu
<Linyu.Yuan@alcatel-sbell.com.cn> wrote:
> I think there are newbie include me still use ifconfig utility.
> So when I check this code, it can be optimized.
>

Working on Linux kernel is always welcome.

But I don't think this can convince DaveM to take your patch even
if it is really correct (I never check).
