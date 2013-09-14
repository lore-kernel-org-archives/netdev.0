From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/4] isdn: clean up debug format string usage
Date: Fri, 13 Sep 2013 20:03:06 -0400 (EDT)
Message-ID: <20130913.200306.1780775507970613895.davem@davemloft.net>
References: <20130913215204.CD6C031C1FB@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, keescook@chromium.org, isdn@linux-pingi.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755875Ab3INADH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 20:03:07 -0400
In-Reply-To: <20130913215204.CD6C031C1FB@corp2gmr1-1.hot.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 13 Sep 2013 14:52:04 -0700

> From: Kees Cook <keescook@chromium.org>
> Subject: isdn: clean up debug format string usage
> 
> Avoid unneeded local string buffers for constructing debug output.  Also
> cleans up debug calls that contain a single parameter so that they cannot
> be accidentally parsed as format strings.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
