From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND,1/1] cxgb3i: Fix a login over vlan issue
Date: Fri, 25 Dec 2009 18:32:38 -0800 (PST)
Message-ID: <20091225.183238.48491982.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rakesh@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52392
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752095AbZLZCck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2009 21:32:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This doesn't apply cleanly to current net-2.6, please
respin.  Thanks.

davem@sunset:~/src/GIT/net-2.6$ git am --signoff RESEND-1-1-cxgb3i-Fix-a-login-over-vlan-issue.patch 
Applying: cxgb3i: Fix a login over vlan issue
error: patch failed: drivers/scsi/cxgb3i/cxgb3i_offload.c:1566
error: drivers/scsi/cxgb3i/cxgb3i_offload.c: patch does not apply
Patch failed at 0001 cxgb3i: Fix a login over vlan issue
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".
davem@sunset:~/src/GIT/net-2.6$ git am --abort
