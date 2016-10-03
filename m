From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] ipv6 addrconf: disallow rtr_solicits < -1
Date: Tue, 4 Oct 2016 05:01:33 +0900
Message-ID: <CANP3RGe2-hpmnQJnGP6JSwNM1YgL-6mKPF8z-GcFaFu7yQtapQ@mail.gmail.com>
References: <1475476917-17382-1-git-send-email-zenczykowski@gmail.com> <CAM_iQpUaXf6crCbbe3+MKsuchJGBE5hnQEDibgFe-MtBoe2v7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:35100 "EHLO
        mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752738AbcJCUBe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 16:01:34 -0400
Received: by mail-yw0-f176.google.com with SMTP id t193so35797109ywc.2
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 13:01:34 -0700 (PDT)
In-Reply-To: <CAM_iQpUaXf6crCbbe3+MKsuchJGBE5hnQEDibgFe-MtBoe2v7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is if you don't want build warnings about discarding 'const' qualifier.
