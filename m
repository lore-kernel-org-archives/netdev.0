From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 00/11] skb_put_zero() used to optimize code
Date: Thu, 15 Jun 2017 08:58:45 +0200
Message-ID: <1497509925.2518.2.camel@sipsolutions.net>
References: <1497450634-3581-1-git-send-email-cugyly@163.com>
         (sfid-20170614_163132_934852_0520825B) <1497451356.9377.1.camel@sipsolutions.net>
         <1497452424.3765.3.camel@163.com>
         <1497457773.9377.2.camel@sipsolutions.net>
         <1497457908.9377.4.camel@sipsolutions.net>
         <8729016553E3654398EA69218DA29EEF15BC8D15@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        "cugyly@163.com" <cugyly@163.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:45834 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750791AbdFOG6w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 02:58:52 -0400
In-Reply-To: <8729016553E3654398EA69218DA29EEF15BC8D15@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-14 at 23:45 +0000, YUAN Linyu wrote:
> > 
> > But still a few more, I think that you didn't find, e.g.
> > in mac80211.
> 
> Yes, I thought you already done in mac80211

So did I, but I also only applied my spatch :)

johannes
