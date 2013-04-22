From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net-next: ipv4: type issue, remove erroneous semicolon
Date: Mon, 22 Apr 2013 15:44:23 -0400 (EDT)
Message-ID: <20130422.154423.1695741341535269869.davem@davemloft.net>
References: <51750E31.2010906@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754862Ab3DVToZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 15:44:25 -0400
In-Reply-To: <51750E31.2010906@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>
Date: Mon, 22 Apr 2013 18:17:21 +0800

>   need remove erroneous semicolon.
> 
>   the related commit number: c54419321455631079c7d6e60bc732dd0c5914c5
> 
>   Find it by EXTRA_CFLAGS=-W
> 
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>

First, what is a "type issue", you aren't changing any variable
or declaration types in this change.

Second, your formatting of your commit messages is terrible.

Do not indent the description with two spaces, just keep them at the
leftmost column.  Where did you learn to indent things like that, who
else does that?  If you've never seen it before, don't invent things.

It is very irritating when we see people write commit messages with
their own style rather than mimicking what other successful
contributors are doing.

Thanks.
