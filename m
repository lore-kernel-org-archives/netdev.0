From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH iproute2 v2 1/3] ifstat: Add extended statistics to ifstat
Date: Mon, 19 Dec 2016 06:10:04 +0200
Message-ID: <CAJ3xEMg9=LFrQW=8yY_bL16rwUjnPJfdeV9n7ABjz1=jj1Ez_Q@mail.gmail.com>
References: <1481806845-63384-1-git-send-email-nogahf@mellanox.com> <1481806845-63384-2-git-send-email-nogahf@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Nogah Frankel <nogahf@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35248 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752170AbcLSEKF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2016 23:10:05 -0500
Received: by mail-oi0-f66.google.com with SMTP id v84so17930913oie.2
        for <netdev@vger.kernel.org>; Sun, 18 Dec 2016 20:10:05 -0800 (PST)
In-Reply-To: <1481806845-63384-2-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2016 at 3:00 PM, Nogah Frankel <nogahf@mellanox.com> wrote:

> +/* Note: if one xstat name in subset of another, it should be before it in this
> + * list.
> + * Name length must be under 64 chars.
> + */

nit "in subset" --> "is subset" ?
