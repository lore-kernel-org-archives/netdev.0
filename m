From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: Soft lockup in tc_classify
Date: Mon, 12 Dec 2016 23:18:22 +0200
Message-ID: <CAJ3xEMjABmvAMs6h0EqBgPH8QDDwF_x0COx01MkEw2pa+fp7LA@mail.gmail.com>
References: <c1c394d3-3aea-52a8-89e3-be57d4d46b8e@mellanox.com>
 <7394f89e-e8a5-5fb2-ee04-63bf1c4ef6e7@mellanox.com> <584EA60B.80803@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shahar Klein <shahark@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Roi Dayan <roid@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:33874 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753064AbcLLVSY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 16:18:24 -0500
Received: by mail-oi0-f43.google.com with SMTP id y198so102481519oia.1
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 13:18:23 -0800 (PST)
In-Reply-To: <584EA60B.80803@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2016 at 3:28 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:

> Note that there's still the RCU fix missing for the deletion race that
> Cong will still send out, but you say that the only thing you do is to
> add a single rule, but no other operation in involved during that test?

What's missing to have the deletion race fixed? making a patch or
testing to a patch which was sent?
