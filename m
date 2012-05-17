From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] pppoe: remove unused return value from
 two methods.
Date: Thu, 17 May 2012 15:35:46 -0400 (EDT)
Message-ID: <20120517.153546.392806740477243395.davem@davemloft.net>
References: <CAHLOa7RiNcZBLE7z7JTY-7WJGOL_DTYq33hmwyTdM0HWqn_WgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755144Ab2EQTfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 15:35:48 -0400
In-Reply-To: <CAHLOa7RiNcZBLE7z7JTY-7WJGOL_DTYq33hmwyTdM0HWqn_WgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Thu, 17 May 2012 18:04:50 +0300

> Hi,
> 
>  The patch removes unused return value from __delete_item() and
>  delete_item() methods in drivers/net/ppp/pppoe.c.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, but please in the future:

1) Don't put "hi," "how are you" and things like in your message
   body, I have to edit them out every time when I commit your
   changes.

2) Remove that leading space from your commit message lines, I have
   to edit those out as well.

Thank you.
