From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] net: vnet: relocate netlink code section comment
Date: Mon, 20 Jul 2015 10:07:00 -0700
Message-ID: <CAHA+R7P63k8Fy+2fcXDdj1fKhYs+CUq=AihnoF7weM3ROnLnHA@mail.gmail.com>
References: <7f4c030ea15ee6217af4809c834a7cbebcd66709.1437291650.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:33774 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754397AbbGTRHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 13:07:01 -0400
Received: by ykfw194 with SMTP id w194so63681774ykf.0
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 10:07:00 -0700 (PDT)
In-Reply-To: <7f4c030ea15ee6217af4809c834a7cbebcd66709.1437291650.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 19, 2015 at 12:40 AM, Baruch Siach <baruch@tkos.co.il> wrote:
> The veth_setup() routine and the VETH_FEATURES macro are also part of the
> netlink interface (referenced from struct rtnl_link_ops). Include them under
> the netlink code section comment.
>

Or just remove it? I don't think comment like this one is useful.
