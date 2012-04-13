From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: bind() use stronger condition for bind_conflict
Date: Fri, 13 Apr 2012 11:12:20 +0300
Message-ID: <CAHG7+CDzOOi3puF3XK3jb8QkqTdyeBNmi5RNbVfDtd-JT_jhyw@mail.gmail.com>
References: <1333698444-24144-1-git-send-email-alex.mihai.c@gmail.com>
	<1334302258.9375.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, fbl@redhat.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55464 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741Ab2DMIMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 04:12:20 -0400
Received: by iagz16 with SMTP id z16so3933845iag.19
        for <netdev@vger.kernel.org>; Fri, 13 Apr 2012 01:12:20 -0700 (PDT)
In-Reply-To: <1334302258.9375.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 13, 2012 at 10:30 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Excellent patch Alex !

Thanks, Eric !

> Two minor coding style problems in this part :
> Correct indentation, and one empty line after variable declaration :

I will fix those. That empty line is missing because that's the way it
was in the code above my changes, but I will add it.

Should I send a v3 or reply here with the new patch ?

Alex Copot
