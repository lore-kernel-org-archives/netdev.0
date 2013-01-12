From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] networking/cs89x0.txt: delete stale
 information about hand patching
Date: Fri, 11 Jan 2013 16:31:12 -0800 (PST)
Message-ID: <20130111.163112.1015838278440673633.davem@davemloft.net>
References: <1357949976-11463-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755262Ab3ALAbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 19:31:15 -0500
In-Reply-To: <1357949976-11463-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 11 Jan 2013 19:19:36 -0500

> Output of a git grep happened to make me look into this file, and
> I found instructions about how to hand patch (without using patch)
> the driver into the kernel tree.
> 
> Since the driver has been a part of the mainline kernel for years,
> we can dump this whole section.  Fortunately it doesn't even cause
> a renumbering of the sections to do so.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

When removing a section you should fix up the numbers of the
remaining sections and any cross references within.
