From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] ipv6: fix redefinition of in6_pktinfo and ip6_mtuinfo
Date: Fri, 6 Feb 2015 22:39:49 -0800
Message-ID: <CAM_iQpVv3CtmC5cHXF_i=LnaXsP1AOWK4c67DpriRfj98W-DCw@mail.gmail.com>
References: <1420587932-8733-1-git-send-email-xiyou.wangcong@gmail.com>
	<20150108.193819.258816805892789860.davem@davemloft.net>
	<54D4512A.5080809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	vlee@twopensource.com
To: "Carlos O'Donell" <carlos@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:50592 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbbBGGju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2015 01:39:50 -0500
Received: by mail-pa0-f47.google.com with SMTP id lj1so21861763pab.6
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 22:39:49 -0800 (PST)
In-Reply-To: <54D4512A.5080809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Carlos

On Thu, Feb 5, 2015 at 9:29 PM, Carlos O'Donell <carlos@redhat.com> wrote:
>
> When does this hit mainline? I've got Cong's patch ready for glibc, but
> the usual procedure is to commit after mainline has the matching patch.
> Not that it really matters, but it's just a useful thing to be able to
> say the trickle down is linux->glibc.
>

It will be merged in the next merge window, currently it is just in net-next.

Thanks.
