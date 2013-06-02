From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: Cocci spatch "ptr_ret.spatch"
Date: Sat, 01 Jun 2013 19:37:17 -0700 (PDT)
Message-ID: <20130601.193717.2203825358470502762.davem@davemloft.net>
References: <1370080751.29224.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thomas@m3y3r.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab3FBChS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 22:37:18 -0400
In-Reply-To: <1370080751.29224.37.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Meyer <thomas@m3y3r.de>
Date: Sat, 01 Jun 2013 11:59:11 +0200

> 
> Signed-off-by: Thomas Meyer <thomas@m3y3r.de>

This obscure reference to the cocci path you used to find/fix
this problem is insufficient in detail for a commit log message.

You must explain exactly what the problem is, and how you fixed
it, in full sentences.   You must make your commit header lin
subject more appropriate as well.
