From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net: allow setting mac address of loopback device
Date: Fri, 31 Jan 2014 16:42:31 -0800
Message-ID: <CAM_iQpVj0LV10EwyP_89fNxyy0B0vTddHAzLiw5yEWC9QiH==Q@mail.gmail.com>
References: <1391038731-7501-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140130144248.GE25336@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:55603 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754503AbaBAAmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 19:42:31 -0500
Received: by mail-ob0-f170.google.com with SMTP id va2so5767713obc.15
        for <netdev@vger.kernel.org>; Fri, 31 Jan 2014 16:42:31 -0800 (PST)
In-Reply-To: <20140130144248.GE25336@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 6:42 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> IFF_LIVE_ADDR_CHANGE would also be helpful to change mac address if loopback
> is already up.
>

Yeah, makes sense for me.
