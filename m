From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: bind() use stronger condition for
 bind_conflict
Date: Fri, 13 Apr 2012 07:53:33 +0200
Message-ID: <1334296413.5300.8416.camel@edumazet-glaptop>
References: <1333698444-24144-1-git-send-email-alex.mihai.c@gmail.com>
	 <CAEnQRZALcP8AOOPzu0_Nn+FGbTDu_geSj-AzGNe39E4GHitFSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alex.mihai.c@gmail.com, davem@davemloft.net, fbl@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:50850 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935Ab2DMFxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 01:53:38 -0400
Received: by wgbdr13 with SMTP id dr13so2672153wgb.1
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 22:53:37 -0700 (PDT)
In-Reply-To: <CAEnQRZALcP8AOOPzu0_Nn+FGbTDu_geSj-AzGNe39E4GHitFSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-13 at 08:36 +0300, Daniel Baluta wrote:

> Eric, David can you have a look on this?


Hi Daniel

I can, but can you provide me the sources of the tests you ran ?

(I am kind of busy these days)

Thanks
