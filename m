From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Documentation: remove obsolete
 networking/multicast.txt file
Date: Mon, 21 Jan 2013 13:54:25 -0500 (EST)
Message-ID: <20130121.135425.1070170828557144836.davem@davemloft.net>
References: <1358785061-17985-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41060 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755Ab3AUSy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 13:54:28 -0500
In-Reply-To: <1358785061-17985-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 21 Jan 2013 11:17:41 -0500

> The original intent of this file was to list limitations in
> drivers/hardware relating to multicast use, back when some
> modest hardware from the early 1990s did not support things
> we might take for granted today.
> 
> I was intending to delete some now-gone MCA/token ring entries
> in this file, but once I opened it, I found it only contained
> information on the earliest (pre-2000) linux networking drivers.
> 
> Checking the git history shows that the file hasn't been touched
> since 2005.  Clearly nobody is actively consulting this file
> as a meaningful reference.
> 
> Rather than add a "YES YES YES" line for all of the drivers we
> currently have, lets just take advantage of the fact that nobody
> is using the file to delete it.
> 
> This has the side benefit of not having to do a line-by-line
> deletion of the file content as each older driver is expired.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks Paul.
