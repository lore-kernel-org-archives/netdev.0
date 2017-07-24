From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 2/6] bnxt: fix unused variable warnings
Date: Mon, 24 Jul 2017 10:50:33 -0700
Message-ID: <CACKFLinci5fv4TbSS4H12P_c1d=Q96iCYqnwmJ_jLKjiW2gKYw@mail.gmail.com>
References: <20170724172523.13135-1-sthemmin@microsoft.com> <20170724172523.13135-3-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
        David Miller <davem@davemloft.net>, pablo@netfilter.org,
        kadlec@blackhole.kfki.hu, fw@strlen.de,
        Netdev <netdev@vger.kernel.org>, linux-bluetooth@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:35749 "EHLO
        mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754123AbdGXRuf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 13:50:35 -0400
Received: by mail-yw0-f172.google.com with SMTP id h189so28359994ywf.2
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 10:50:34 -0700 (PDT)
In-Reply-To: <20170724172523.13135-3-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 10:25 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> Fix a couple of warnings where variable =E2=80=98txq=E2=80=99 set but not=
 used
>
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Acked-by: Michael Chan <michael.chan@broadcom.com>v, i);
