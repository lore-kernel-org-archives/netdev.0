From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] net: fix a lockdep splat
Date: Thu, 23 Sep 2010 15:32:23 +0900
Message-ID: <201009231532.JFD65132.OFtFSVFJHQOMLO@I-love.SAKURA.ne.jp>
References: <201009220858.o8M8w8s3094017@www262.sakura.ne.jp>
	<1285176935.2639.453.camel@edumazet-laptop>
	<1285184088.2380.18.camel@edumazet-laptop>
	<4C9A7F7F.5010507@gmail.com>
	<1285195419.2380.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com, jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:60487 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750709Ab0IWGcb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 02:32:31 -0400
In-Reply-To: <1285195419.2380.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> [PATCH v2] net: fix a lockdep splat

The lockdep warning disappeared for both
linux-2.6.35.5.tar.bz2 and linux-2.6.36-rc5.tar.bz2 .

Thank you.
