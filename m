From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Kill directly reference of netdev->priv
Date: Mon, 08 Dec 2008 23:34:19 -0800 (PST)
Message-ID: <20081208.233419.68620214.davem@davemloft.net>
References: <20081208145333.GB6830@ubuntu>
	<20081208.122742.46904963.davem@davemloft.net>
	<20081209013241.GA15483@ubuntu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jianjun@zeuux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50049
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751950AbYLIHeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 02:34:19 -0500
In-Reply-To: <20081209013241.GA15483@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianjun Kong <jianjun@zeuux.org>
Date: Tue, 9 Dec 2008 09:32:41 +0800

> 
> another new patch for net-next-2.6

Please stop sending these patches, I am ignoring all of them.

I told you that all the conversions have been done already
and these casts you are doing here are unbelievably ugly
and are a big red flag indicating that your patches are wrong.
