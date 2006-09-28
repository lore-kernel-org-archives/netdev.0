From: David Miller <davem@davemloft.net>
Subject: Re: Bluetooth update for 2.6
Date: Wed, 27 Sep 2006 22:58:17 -0700 (PDT)
Message-ID: <20060927.225817.106770711.davem@davemloft.net>
References: <1158868040.11194.56.camel@localhost>
	<1159267581.1235.10.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:12471
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161011AbWI1F6S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 01:58:18 -0400
To: marcel@holtmann.org
In-Reply-To: <1159267581.1235.10.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Tue, 26 Sep 2006 12:46:21 +0200

> > here are the pending patches that didn't make it into the 2.6.18 kernel
> > release. I have some additional fixes, but all of them need some more
> > additional testing from my side.
> 
> it seems that you haven't pulled in these changes so far. So I didn't
> rebase the tree and simply pushed some additional ones on top of it. All
> three of them address the issues we had with non-blocking connects.

I applied all of your fixes into my tree, sorry for taking so long.
