From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RESEND 1/2] FDDI: Reformat <linux/if_fddi.h>
 for 8-character tabs
Date: Sun, 27 Apr 2014 19:08:48 -0400 (EDT)
Message-ID: <20140427.190848.1109909932563072745.davem@davemloft.net>
References: <alpine.LFD.2.11.1404250157020.11598@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35151 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751607AbaD0XIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 19:08:49 -0400
In-Reply-To: <alpine.LFD.2.11.1404250157020.11598@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Fri, 25 Apr 2014 10:35:07 +0100 (BST)

> Some of our FDDI support code has been apparently written with an 
> assumption that tabs are 4-character wide.  In preparation to the next
> change this update reformats <linux/if_fddi.h> so that it stays within 79 
> columns and otherwise renders correctly with 8-character tabs.  No 
> functional change.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

Applied.
