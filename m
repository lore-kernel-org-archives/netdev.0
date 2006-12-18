From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [patch sungem] improved locking
Date: Mon, 18 Dec 2006 12:41:50 +1100
Message-ID: <1166406110.4976.2.camel@localhost.localdomain>
References: <1165901783.11914.36.camel@localhost.localdomain>
	 <5cac192f0612112149i14583a31p7fa7c5496efaa94a@mail.gmail.com>
	 <1166144346.31351.41.camel@localhost.localdomain>
	 <20061217.171512.132926634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.lemoine@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60983 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301AbWLRBl6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Dec 2006 20:41:58 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061217.171512.132926634.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Thanks for testing this stuff.
> 
> I'll take a look at the pause-enabling issue in the sungem
> drive then work on integrating Eric's patch.

Ok, thanks.

> Probably we'll need to put this in post-2.6.20 as the merge
> window is closed.

Yup, no hurry there.

Ben.


