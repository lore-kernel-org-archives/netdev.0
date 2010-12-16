From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12 net-next] cxgb4 update v2
Date: Thu, 16 Dec 2010 12:10:11 -0800 (PST)
Message-ID: <20101216.121011.39196012.davem@davemloft.net>
References: <1292398615-26527-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58072
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751066Ab0LPUJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 15:09:43 -0500
In-Reply-To: <1292398615-26527-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Tue, 14 Dec 2010 23:36:43 -0800

> 
> This is v2 of the cxgb4 series.  I've removed the fallback call to kcalloc in
> patch 12 per Eric's comment and restored an accidentally removed increment in
> patch 7.

All applied.

I made one change, I made sure that for Joe Perches's patch he will be
set as the author in the tree.

Next time you have a patch written by someone else, start the commit
message with:

From: NAME <EMAIL>

and GIT will take care of the rest.

Thanks.
