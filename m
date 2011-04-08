From: David Miller <davem@davemloft.net>
Subject: Re: shutdown(2) does not fully shut down socket any more
Date: Fri, 08 Apr 2011 15:24:27 -0700 (PDT)
Message-ID: <20110408.152427.193714809.davem@davemloft.net>
References: <20110408221046.GW4050@outflux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kees.cook@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60526
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751640Ab1DHWZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 18:25:03 -0400
In-Reply-To: <20110408221046.GW4050@outflux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <kees.cook@canonical.com>
Date: Fri, 8 Apr 2011 15:10:46 -0700

> Hey all,
> 
> I've got a weird regression visible here:
> https://bugzilla.kernel.org/show_bug.cgi?id=32832
> 
> Can other people reproduce this, and if so, what's going on? Seems like a
> kernel bug unless I'm misunderstanding something.

Eric Dumazet will be working on fixing this, see:

http://marc.info/?l=linux-netdev&m=130176733401613&w=2

And Stephem Hemminger already forward that bugzilla entry here
at few days ago.


