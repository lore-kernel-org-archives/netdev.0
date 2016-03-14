From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH next v2 0/7] Introduce l3_dev pointer for L3 processing
Date: Mon, 14 Mar 2016 11:15:09 -0700
Message-ID: <CAM_iQpVx_DgCPYBXq+1cZFeK+znsXpFKiu_YEV6YdcjOE1X7ag@mail.gmail.com>
References: <1457560189-12870-1-git-send-email-mahesh@bandewar.net>
	<20160313.215033.17951850162749485.davem@davemloft.net>
	<CAF2d9jhtvvEdmwP8OrOcUEn+P-Di0TRnjR7-RpcJrKJ3+HAN-Q@mail.gmail.com>
	<20160313.235358.1007563444789525672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <maheshb@google.com>,
	Mahesh Bandewar <mahesh@bandewar.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:35504 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932797AbcCNSPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 14:15:10 -0400
Received: by mail-yw0-f172.google.com with SMTP id g127so178115591ywf.2
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 11:15:09 -0700 (PDT)
In-Reply-To: <20160313.235358.1007563444789525672.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 13, 2016 at 8:53 PM, David Miller <davem@davemloft.net> wrote:
>
> Please stop pretending that this device switching is ok, it's not.

+1
This is what I have been complaining about since v1...
