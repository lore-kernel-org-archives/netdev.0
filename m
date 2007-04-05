From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/4] 8139too: RTNL and flush_scheduled_work deadlock
Date: Thu, 5 Apr 2007 13:17:52 +0200
Message-ID: <20070405111752.GA26566@electric-eye.fr.zoreil.com>
References: <20070215223744.GC19840@electric-eye.fr.zoreil.com> <46143704.7020802@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39535 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992435AbXDELVf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 07:21:35 -0400
Content-Disposition: inline
In-Reply-To: <46143704.7020802@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> :
[...]
> It looks like this has not made it into the 2.6.20 stable series
> patches...  Any reason not to add it there?

No. Go ahead and submit it.

-- 
Ueimor

Anybody got a battery for my Ultra 10 ?
