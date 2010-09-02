From: David Miller <davem@davemloft.net>
Subject: Re: Some git warning on net-next-2.6 ?
Date: Thu, 02 Sep 2010 09:20:42 -0700 (PDT)
Message-ID: <20100902.092042.226778759.davem@davemloft.net>
References: <1283409272.2484.138.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56515
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753480Ab0IBQUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 12:20:25 -0400
In-Reply-To: <1283409272.2484.138.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Sep 2010 08:34:32 +0200

> FYI
> 
> [root@edumazet /opt/src/net-next-2.6]$ git pull
> error: * Ignoring funny ref 'refs/remotes/origin/master~' locally
> Already up-to-date.
> 
> 
> Same thing on another machine as well

I had to quickly undo a bad push, and I edited the master file
by hand to do it, and emacs left a backup file as a result :-)

I removed the backup file, thanks for the heads up.
