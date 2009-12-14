From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix userspace RTM_NEWLINK notifications.
Date: Sun, 13 Dec 2009 19:45:46 -0800 (PST)
Message-ID: <20091213.194546.39171259.davem@davemloft.net>
References: <m1fx7fmgyk.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50699
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754148AbZLNDpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 22:45:45 -0500
In-Reply-To: <m1fx7fmgyk.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 13 Dec 2009 00:11:15 -0800

> 
> I received some bug reports about userspace programs having problems
> because after RTM_NEWLINK was received they could not immediate access
> files under /proc/sys/net/ because they had not been registered yet.
 ...
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>

Applied, thanks Eric.
