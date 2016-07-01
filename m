From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: horizon: Use setup_timer
Date: Fri, 01 Jul 2016 05:58:49 -0400 (EDT)
Message-ID: <20160701.055849.1834842849806561121.davem@davemloft.net>
References: <20160630084401.GA5261@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbcGAJ7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 05:59:45 -0400
In-Reply-To: <20160630084401.GA5261@amitoj-Inspiron-3542>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Thu, 30 Jun 2016 14:14:01 +0530

> Convert a call to init_timer and accompanying intializations of
> the timer's data and function fields to a call to setup_timer.
> 
> The Coccinelle semantic patch that fixes this problem is
> as follows:
 ...
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Applied, thanks.
