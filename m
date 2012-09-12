From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH] ipv6: replace write lock with read lock when get route info
Date: Wed, 12 Sep 2012 15:49:08 +0800
Message-ID: <CAJFZqHyk3O-8wQCmUGBOBkGvoYrY9JicWLxTX9ZZaF=QO4fWVQ@mail.gmail.com>
References: <1347427553-17781-1-git-send-email-roy.qing.li@gmail.com>
	<1347435907.13103.693.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:38237 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755193Ab2ILHtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 03:49:09 -0400
Received: by obbuo13 with SMTP id uo13so2191614obb.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 00:49:08 -0700 (PDT)
In-Reply-To: <1347435907.13103.693.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>
> Why dont you also change addrconf_get_prefix_route() ?
>
>

I did not find it, I will send v2
Thanks

-Roy
