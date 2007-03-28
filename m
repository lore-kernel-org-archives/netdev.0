From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Established connections hash function
Date: Wed, 28 Mar 2007 22:12:45 +0200
Message-ID: <20070328201245.GA10974@one.firstfloor.org>
References: <200703281129.43783.ak@suse.de> <20070328104505.GA18748@2ka.mipt.ru> <p73y7lh316u.fsf@bingen.suse.de> <20070328.120429.98555893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, johnpol@2ka.mipt.ru, nikb@webmaster.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:54191 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965747AbXC1UMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 16:12:48 -0400
Content-Disposition: inline
In-Reply-To: <20070328.120429.98555893.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> In my patch the random seed is initialized when the first TCP or DCCP
> socket is created, at which point we'll have sufficient entropy.

See my discussion of this case in a later mail to Evgeniy 

-Andi
