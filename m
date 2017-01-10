From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/7] flow_dissector: make local function static
Date: Tue, 10 Jan 2017 10:43:36 -0800
Message-ID: <20170110104336.734bb4c4@xeon-e3>
References: <20170110181816.18991-1-sthemmin@microsoft.com>
        <20170110181816.18991-2-sthemmin@microsoft.com>
        <20170110.133201.2103096039977087636.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34424 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932344AbdAJSno (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:43:44 -0500
Received: by mail-pf0-f170.google.com with SMTP id 127so51108881pfg.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 10:43:44 -0800 (PST)
In-Reply-To: <20170110.133201.2103096039977087636.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jan 2017 13:32:01 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Tue, 10 Jan 2017 10:18:10 -0800
>=20
> > Fix warning: no previous prototype for =E2=80=98skb_flow_get_be16=E2=80=
=99
> > Function is only used in this file, make it static.
> >=20
> > Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com> =20
>=20
> Eric Dumazet already posted a patch which does this.

Yeah it looks like several of these got posted today.
