From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] 6lowpan: Various bug fixes
Date: Mon, 16 Jul 2012 22:52:18 -0700 (PDT)
Message-ID: <20120716.225218.390766894768297.davem@davemloft.net>
References: <1342025476-20949-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alex.bluesman.smirnov@gmail.com
To: tony.cheneau@amnesiak.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab2GQFwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:52:19 -0400
In-Reply-To: <1342025476-20949-1-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Cheneau <tony.cheneau@amnesiak.org>
Date: Wed, 11 Jul 2012 12:51:13 -0400

> After reading and playing with the 6lowpan code, I found out a few issues. This
> patchset fixes them. This patchset should apply cleanly against the current
> net-next. It contains only bug fixes, I'll send later on an other patchset that
> will contain new functionalities.
> 
> Changes since version 2:
> - remove a patch that prevented fragmentation to work after few packets have
>   been send: Alexander included the patch in his patchset
> - fix the title of the git commit to include the "6lowpan" tag

Series applied, thanks.
