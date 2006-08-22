From: David Miller <davem@davemloft.net>
Subject: Re: [Lksctp-developers] [PATCH 3/5][SCTP]: Remove multiple levels
 of msecs to jiffies conversions.
Date: Tue, 22 Aug 2006 13:28:47 -0700 (PDT)
Message-ID: <20060822.132847.129770563.davem@davemloft.net>
References: <1155925357.20802.27.camel@w-sridhar2.beaverton.ibm.com>
	<20060822.002253.26973121.davem@davemloft.net>
	<200608220944.37254.vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, sri@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37840
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932083AbWHVU23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 16:28:29 -0400
To: vladislav.yasevich@hp.com
In-Reply-To: <200608220944.37254.vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 22 Aug 2006 09:44:37 -0400

> Again, the variables exposed by the user interface have been and remain in 
> milliseconds.

I misread the patch, sorry :)

Thanks for clearing this up, I'll apply the patch.
