From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] tcp: Check daddr_cache before use in tracepoint
Date: Mon, 16 Oct 2017 16:08:28 -0600
Message-ID: <b7bbe2e3-5eca-230b-4820-adc097bfca86@gmail.com>
References: <1508189387-27931-1-git-send-email-dsahern@gmail.com>
 <CAM_iQpUgWJwjaRYw3vX4t20foheOrebU3U2ACZqrAbTYqYc-5A@mail.gmail.com>
 <cfd6b39a-41a6-ccf6-80a7-07089a2d6fea@gmail.com>
 <CAM_iQpVy-YY+e1R17P_9uV22n5DbXxL8+ACpY+E5yJYdp8doAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:55728 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932312AbdJPWIa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 18:08:30 -0400
Received: by mail-pg0-f44.google.com with SMTP id b11so7912917pgn.12
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 15:08:30 -0700 (PDT)
In-Reply-To: <CAM_iQpVy-YY+e1R17P_9uV22n5DbXxL8+ACpY+E5yJYdp8doAQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/17 4:05 PM, Cong Wang wrote:
> Or if you mean non-zero, they are set to LOOPBACK4_IPV6
> which is what I expect.

yes, I meant non-0. thanks for the explanation. I'll send a v2
