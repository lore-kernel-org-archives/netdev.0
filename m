From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next v2 4/9] net: ipmr: fix code and comment style
Date: Sun, 22 Nov 2015 21:30:15 -0800
Message-ID: <CAHA+R7ONwRv5cM8kn-7RML+3ezhEs5D8zxt7ZrneyWtwSUGAXw@mail.gmail.com>
References: <1448117852-4254-1-git-send-email-razor@blackwall.org>
	<1448117852-4254-5-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:35841 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbbKWFaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 00:30:16 -0500
Received: by ykdr82 with SMTP id r82so225337618ykd.3
        for <netdev@vger.kernel.org>; Sun, 22 Nov 2015 21:30:15 -0800 (PST)
In-Reply-To: <1448117852-4254-5-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 21, 2015 at 6:57 AM, Nikolay Aleksandrov
<razor@blackwall.org> wrote:
> -
> -/*
> - *     Setup for IP multicast routing
> - */
> +/* Setup for IP multicast routing */
>  static int __net_init ipmr_net_init(struct net *net)

Comments like this one are never useful so can be just removed.
