From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -stable] multiple backports requested
Date: Fri, 13 Nov 2015 16:10:32 -0500 (EST)
Message-ID: <20151113.161032.1223894063965320473.davem@davemloft.net>
References: <1447445591.2645.17.camel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: 3chas3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40061 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbbKMVKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 16:10:34 -0500
In-Reply-To: <1447445591.2645.17.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Charles (Chas) Williams" <3chas3@gmail.com>
Date: Fri, 13 Nov 2015 15:13:11 -0500

> Dave, could you please add the following backports?
> 
> For the 3.14.y stable queue:

I am no longer handling 3.14.y -stable submissions, sorry...

> For the 4.1.y stable queue:
> 
> 	commit 74e98eb085889b0d2d4908f59f6e00026063014f
> 	RDS: verify the underlying transport exists before creating a connection
> 	This addresses CVE-2015-6937

Queued up for 3.18, 4.1, and 4.2.
