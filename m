From: David Miller <davem@davemloft.net>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Tue, 18 Jul 2006 01:34:37 -0700 (PDT)
Message-ID: <20060718.013437.80029473.davem@davemloft.net>
References: <20060718081625.GA13830@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31155
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751221AbWGRIeR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 04:34:17 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060718081625.GA13830@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 18 Jul 2006 12:16:26 +0400

> I would ask to push netchannel support into -mm tree, but I expect
> in advance that having two separate TCP stacks (one of which can
> contain some bugs (I mean atcp.c)) is not that good idea, so I
> understand possible negative feedback on that issue, but it is much
> better than silence.

Evgeniy, you are present in my queue of work to review.

Perhaps I am mistaken with my priorities, but I tend to hit all the
easy patches and bug fixes first, before significant new work.

And even in the realm of new work, your things require the most
serious thinking and consideration.  I apologize for the time it takes
me, therefore, to get to reviewing deep work such as your's.

I will make a real effort to properly review your excellent work this
week, and I encourage any other netdev hackers with some spare
cycles to do the same. :)

Thanks!
