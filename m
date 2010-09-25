From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix a lockdep splat
Date: Fri, 24 Sep 2010 22:26:37 -0700 (PDT)
Message-ID: <20100924.222637.212692152.davem@davemloft.net>
References: <4C9A7F7F.5010507@gmail.com>
	<1285195419.2380.39.camel@edumazet-laptop>
	<201009231532.JFD65132.OFtFSVFJHQOMLO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jarkao2@gmail.com,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44474
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754788Ab0IYF0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Sep 2010 01:26:17 -0400
In-Reply-To: <201009231532.JFD65132.OFtFSVFJHQOMLO@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 23 Sep 2010 15:32:23 +0900

> Eric Dumazet wrote:
>> [PATCH v2] net: fix a lockdep splat
> 
> The lockdep warning disappeared for both
> linux-2.6.35.5.tar.bz2 and linux-2.6.36-rc5.tar.bz2 .

Thanks everyone, I've applied Eric's patch to net-2.6

