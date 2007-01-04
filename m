From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sungem: PHY updates & pause fixes
Date: Thu, 04 Jan 2007 12:27:16 -0800 (PST)
Message-ID: <20070104.122716.58455250.davem@davemloft.net>
References: <1167802802.6165.129.camel@localhost.localdomain>
	<20070103.185521.64808473.davem@davemloft.net>
	<5cac192f0701041206x421824e9oedcd6a8e5c814f8b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37015
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030187AbXADU1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 15:27:17 -0500
To: eric.lemoine@gmail.com
In-Reply-To: <5cac192f0701041206x421824e9oedcd6a8e5c814f8b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric Lemoine" <eric.lemoine@gmail.com>
Date: Thu, 4 Jan 2007 21:06:48 +0100

> On 1/4/07, David Miller <davem@davemloft.net> wrote:
> > I've applied that patch, thanks.
> 
> David, I suppose you've applied the locking patch as well...

No, not yet.

Your locking patches are definitely 2.6.21 material, but
Ben's changes fix PAUSE handling bugs so I want to
put his patch into 2.6.20

I'll put your locking bits into 2.6.21, don't worry :-)
