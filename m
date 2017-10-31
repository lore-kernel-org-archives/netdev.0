From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: iproute2 compile and linking errors on Fedora 19
Date: Tue, 31 Oct 2017 16:28:20 -0700
Message-ID: <CAM_iQpWQ=jXbkFMaG4siav2+nBUSszN_PtYmw9k__TrJLzQtwg@mail.gmail.com>
References: <CAM_iQpV07bZscuS5g6nZJ1Ko_RYVv7QyxVtga_Ky5EnbxXhCug@mail.gmail.com>
 <20171031221006.13cf9be8@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Phil Sutter <phil@nwl.cc>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:54839 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933120AbdJaX2l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 19:28:41 -0400
Received: by mail-pf0-f170.google.com with SMTP id n89so483279pfk.11
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 16:28:40 -0700 (PDT)
In-Reply-To: <20171031221006.13cf9be8@shemminger-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 2:10 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> IPPROTO_MH comes from include/uapi/linux/in6.h
> Maybe it is trying to use old kernel headers from libc.

So newer iproute2 is not supposed to work with older
kernel header??
