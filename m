From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 7/9] qlcnic: Validate Tx queue only for
 82xx adapters.
Date: Thu, 17 Oct 2013 15:07:52 -0400 (EDT)
Message-ID: <20131017.150752.1363063739180510255.davem@davemloft.net>
References: <cover.1381882600.git.himanshu.madhani@qlogic.com>
	<21b377dba7708434c344a9204afd460c9b43af3c.1381882600.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: himanshu.madhani@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757861Ab3JQTHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 15:07:54 -0400
In-Reply-To: <21b377dba7708434c344a9204afd460c9b43af3c.1381882600.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Date: Tue, 15 Oct 2013 12:57:52 -0400

> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> 
> o validate Tx queue only in case of adapters which supports
>   multi Tx queue.
> 
>   This patch is to fix regression introduced in commit
>   aa4a1f7df7cbb98797c9f4edfde3c726e2b3841f
>   "qlcnic: Enable Tx queue changes using ethtool for 82xx Series adapter"
> 
> Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>

Do not submit bug fixes for "net-next" if they are for problems
that exist in 'net'.

What do several driver maintainers do this repeatedly?

Are you scared I'll reject the submission?  If it's really a bug fix
I won't, 'net' is where it really belongs.

I'm not applying this series, submit it properly.

Thanks.
