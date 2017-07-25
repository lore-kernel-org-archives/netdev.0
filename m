From: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Subject: Re: Bonding driver fails to enable second interface if updelay is non-zero
Date: Mon, 24 Jul 2017 19:19:23 -0700
Message-ID: <CAD3VwcqSskfhSyv9HVcnU_NM+94Toky+8-EE6uY9oVcqX+Z4pw@mail.gmail.com>
References: <CAD3VwcpLXxk_r+4AX47gKdu=5vg7y9PnEdwUeOpSAhOLncqeeg@mail.gmail.com>
 <CAM_iQpU+gGsPsUC-ku7sHnJxPsUTxdrTXu6zzS_q9BPjotRZ3w@mail.gmail.com> <CAF2d9jhh9MKqVdnc3nY7_kAwScRsA19U+t1VU8TqO6UvGBrvCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35950 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754982AbdGYCTY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 22:19:24 -0400
Received: by mail-wm0-f50.google.com with SMTP id t201so33524673wmt.1
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 19:19:24 -0700 (PDT)
In-Reply-To: <CAF2d9jhh9MKqVdnc3nY7_kAwScRsA19U+t1VU8TqO6UvGBrvCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 2:34 PM, Mahesh Bandewar (=E0=A4=AE=E0=A4=B9=E0=A5=
=87=E0=A4=B6 =E0=A4=AC=E0=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE=E0=A4=
=B0)
<maheshb@google.com> wrote:
> Having said that, the proposed solution (Cong's patch) should fix it, ple=
ase
> give it a try so that this fix can be formalized.

The patch fixes the problem for me.

Thanks!
--Benjamin Gilbert
