From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net] ipv6: kill sk_dst_lock
Date: Thu, 3 Dec 2015 08:49:59 -0800
Message-ID: <CANn89iKYvoAnCcj8VDCpjYV5zmXW6W3B8riGUdEBveN9XFH2cg@mail.gmail.com>
References: <1448901315.24696.127.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151202.234216.1113392733011218992.davem@davemloft.net>
	<1449122037.6379.18.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151203.113243.972969856777923620.davem@davemloft.net>
	<CANn89iJAbL+RJMhpFk552oV13VsQJwVoZ4GrFiAWSe+5aFUfFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36303 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbbLCQuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 11:50:00 -0500
Received: by wmww144 with SMTP id w144so29340365wmw.1
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 08:49:59 -0800 (PST)
In-Reply-To: <CANn89iJAbL+RJMhpFk552oV13VsQJwVoZ4GrFiAWSe+5aFUfFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 3, 2015 at 8:49 AM, Eric Dumazet <edumazet@google.com> wrote:
> Hmm... I got lazy yesterday night I sent the same patch from my
> laptop, only changelog was updated.

Sorry for top posting.
