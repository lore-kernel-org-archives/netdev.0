From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] X25: Remove bkl in sockopts
Date: Mon, 17 May 2010 17:39:52 -0700 (PDT)
Message-ID: <20100517.173952.233710014.davem@davemloft.net>
References: <1274086835.4104.55.camel@ibex>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38729
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755642Ab0ERAjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 20:39:43 -0400
In-Reply-To: <1274086835.4104.55.camel@ibex>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Mon, 17 May 2010 19:00:35 +1000

> 
> Removes the BKL in x25 setsock and getsockopts.
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied.
