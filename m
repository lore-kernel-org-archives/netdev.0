From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] 6lowpan: handle only real link-local
 addresses
Date: Wed, 14 Aug 2013 17:18:25 -0700 (PDT)
Message-ID: <20130814.171825.944941726261089646.davem@davemloft.net>
References: <1376478067-3371-1-git-send-email-alex.aring@gmail.com>
	<20130814.125346.585011183381258117.davem@davemloft.net>
	<20130814211658.GA2075@x61s.8.8.8.8>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014Ab3HOAS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 20:18:28 -0400
In-Reply-To: <20130814211658.GA2075@x61s.8.8.8.8>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Wed, 14 Aug 2013 23:17:01 +0200

> Ok, please let me know what should I do to submit it properly.

What you don't understand is that just because patches aren't
related doesn't mean that their order of application doesn't
matter.

So you put all the patches into a full series so that there is no
ambiguity as to what order the patches are to be applied.

Do not ever seperate patches when you are submitting changes to the
same exact files at one time.
