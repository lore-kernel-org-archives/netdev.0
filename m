From: David Miller <davem@davemloft.net>
Subject: Re: [RFC patch net/next] net: Hoist assigns from if?
Date: Tue, 15 Jun 2010 10:23:05 -0700 (PDT)
Message-ID: <20100615.102305.28825768.davem@davemloft.net>
References: <1276580526.30434.330.camel@edumazet-laptop>
	<20100614.225910.104075511.davem@davemloft.net>
	<1276618932.1586.64.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57795
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757991Ab0FORWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 13:22:54 -0400
In-Reply-To: <1276618932.1586.64.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 15 Jun 2010 09:22:12 -0700

> On Mon, 2010-06-14 at 22:59 -0700, David Miller wrote:
>> But that to me just means that until git has a friendlier way to
>> walk backwards through blame information for a line to skip past
>> the cleanup crapola, we shouldn't make a lot of these kinds of
>> changes.
> 
> What do you think is missing from the gitk file viewer?

I don't use the gitk file viewer, I use "git blame".

Requiring a GUI to get at the information I need is unacceptable.  I
often work remotely and use text consoles for everything, even email
and web browsing.

