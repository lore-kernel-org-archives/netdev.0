From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] qlge: Fix vlan netdev features.
Date: Tue, 14 Jan 2014 19:03:02 -0800 (PST)
Message-ID: <20140114.190302.2246279639331887319.davem@davemloft.net>
References: <1389725845-27469-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	shahed.shaikh@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54665 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722AbaAODDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 22:03:03 -0500
In-Reply-To: <1389725845-27469-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Tue, 14 Jan 2014 13:57:25 -0500

> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> 
> vlan gets the same netdev features except vlan filter.
> 
> Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Applied and queued up for -stable, thanks.
