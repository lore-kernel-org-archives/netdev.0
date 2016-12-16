From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH iproute2 v2 1/3] ifstat: Add extended statistics to ifstat
Date: Fri, 16 Dec 2016 17:21:03 +0200
Message-ID: <CAKoUArk5oSseSGDdZ_TEGLbG-jabdArUmz3pZ7kdoZKiNpqPrQ@mail.gmail.com>
References: <1481806845-63384-1-git-send-email-nogahf@mellanox.com>
 <1481806845-63384-2-git-send-email-nogahf@mellanox.com> <20161215093327.2daf60c6@xeon-e3>
 <DB5PR05MB1895991888E270CE790F1C16AC9C0@DB5PR05MB1895.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Nogah Frankel <nogahf@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35789 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760420AbcLPPaJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 10:30:09 -0500
Received: by mail-it0-f67.google.com with SMTP id b123so2957882itb.2
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 07:30:09 -0800 (PST)
In-Reply-To: <DB5PR05MB1895991888E270CE790F1C16AC9C0@DB5PR05MB1895.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>Thanks, I'll fix it.
Another minor nit, on this occasion:

bool is_extanded should be: bool is_extended

Regards,
Rami Rosen
