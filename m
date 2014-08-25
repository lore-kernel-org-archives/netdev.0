From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: check code with checkpatch.pl
Date: Mon, 25 Aug 2014 12:58:52 -0700 (PDT)
Message-ID: <20140825.125852.744688824103211496.davem@davemloft.net>
References: <1394712342-15778-16-Taiwan-albertk@realtek.com>
	<1394712342-15778-21-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36559 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbaHYT6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 15:58:53 -0400
In-Reply-To: <1394712342-15778-21-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 25 Aug 2014 15:53:00 +0800

>  626: CHECK: Alignment should match open parenthesis
>  646: CHECK: Alignment should match open parenthesis
>  655: CHECK: Alignment should match open parenthesis
>  695: CHECK: Alignment should match open parenthesis
>  729: CHECK: Alignment should match open parenthesis
>  739: CHECK: Alignment should match open parenthesis
>  976: WARNING: externs should be avoided in .c files
>  1314: CHECK: Alignment should match open parenthesis
>  1358: WARNING: networking block comments don't use an empty /* line, use /* Comment...
>  1402: WARNING: networking block comments don't use an empty /* line, use /* Comment...
>  1521: CHECK: multiple assignments should be avoided
>  1775: CHECK: Alignment should match open parenthesis
>  1838: CHECK: multiple assignments should be avoided
>  1843: CHECK: multiple assignments should be avoided
>  1847: CHECK: multiple assignments should be avoided
>  1850: WARNING: Missing a blank line after declarations
>  1864: CHECK: Alignment should match open parenthesis
>  1872: CHECK: braces {} should be used on all arms of this statement
>  1906: CHECK: usleep_range is preferred over udelay
>  2865: WARNING: networking block comments don't use an empty /* line, use /* Comment...
>  3088: CHECK: Alignment should match open parenthesis
>  total: 0 errors, 5 warnings, 16 checks, 3567 lines checked
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
