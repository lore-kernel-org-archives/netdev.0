From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] FDDI: Reformat <linux/if_fddi.h> for 8-character
 tabs
Date: Tue, 08 Apr 2014 12:46:31 -0400 (EDT)
Message-ID: <20140408.124631.2239975325018007505.davem@davemloft.net>
References: <alpine.LFD.2.11.1404080022120.26128@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43563 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbaDHQqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 12:46:32 -0400
In-Reply-To: <alpine.LFD.2.11.1404080022120.26128@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Tue, 8 Apr 2014 13:19:28 +0100 (BST)

> Some of our FDDI support code has been apparently written with an 
> assumption that tabs are 4-character wide.  In preparation to the next
> change this update reformats <linux/if_fddi.h> so that it stays within 79 
> columns and otherwise renders correctly with 8-character tabs.  No 
> functional change.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> ---
> Dave,
> 
>  Please apply or otherwise let me know if you have issues with this 
> change.

Such cleanups are only appropriate for the net-next tree, which is not
open at this time.

Please resubmit this change when the net-next tree is openned back up
for submissions.

Thank you.
