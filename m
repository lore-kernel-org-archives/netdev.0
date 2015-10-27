From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 27 Oct 2015 06:59:24 -0700 (PDT)
Message-ID: <20151027.065924.796277086557445997.davem@davemloft.net>
References: <562F577E.6000901@oracle.com>
	<20151027.064228.237119117273824839.davem@davemloft.net>
	<562F7E16.2070906@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Alan.Burlison@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932329AbbJ0Nmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 09:42:46 -0400
In-Reply-To: <562F7E16.2070906@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Burlison <Alan.Burlison@oracle.com>
Date: Tue, 27 Oct 2015 13:37:26 +0000

> If you took that argument to it's logical extreme they you'd never
> make any changes that made changes to existing behaviour, and that's
> patently not the case.

You know exactly what I mean, and what you're saying here is just a
scarecrow distracting the discussion from the real issue.
