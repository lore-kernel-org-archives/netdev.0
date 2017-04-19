From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: netlink: question about netlink testsuite
Date: Tue, 18 Apr 2017 23:05:56 -0700
Message-ID: <CAM_iQpVZ8f2Dc6xmLW3uzHe1AY+E3k-6cUXjnY678OCPmqAySg@mail.gmail.com>
References: <8B1169046A4CF54A85F712F74A617BA128039167@g01jpexmbkw01>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Yasuhara, Hiroyuki" <h.yasuhara@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38597 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760101AbdDSGGR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 02:06:17 -0400
Received: by mail-wm0-f46.google.com with SMTP id r190so13078733wme.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 23:06:17 -0700 (PDT)
In-Reply-To: <8B1169046A4CF54A85F712F74A617BA128039167@g01jpexmbkw01>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, Apr 18, 2017 at 10:00 PM, Yasuhara, Hiroyuki
<h.yasuhara@jp.fujitsu.com> wrote:
> Hi,
>
> I'm looking for a testset about netlink function,
> for example, making a lot of netlink sockets and
> communicating with them in the testset.
>
> If anyone know such a testset, please give me the information.
>

libnl3 contains some test cases, which may be what you
are looking for:

https://github.com/thom311/libnl/tree/master/tests
