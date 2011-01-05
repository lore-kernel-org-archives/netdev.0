From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/10][pull-request] Intel Wired LAN Driver Updates
Date: Wed, 05 Jan 2011 11:41:06 -0800 (PST)
Message-ID: <20110105.114106.39178014.davem@davemloft.net>
References: <20110105175920.GB23050@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: donald.c.skidmore@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40913
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751331Ab1AETkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 14:40:35 -0500
In-Reply-To: <20110105175920.GB23050@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>
Date: Wed, 5 Jan 2011 09:59:20 -0800

> The following series contains: 
>  - ixgbe flow director improvement patches 
>  - general e1000 cleanup
>  - switches ixgbe to new vlan interface
> 
> The following are changes since commit:
> 
> commit 2316aa2aee254c126e688b53a3a105b82bc3f368
> Author: Greg Rose <gregory.v.rose@intel.com>
>     ixgbevf: Add X540 VF device support to the ixgbevf driver
> 
> and are available in the git repository at:
> 
>      master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6.git master

There's nothing there.

davem@sunset:~/src/GIT/net-next-2.6$ git pull master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6.git master
davem@master.kernel.org's password: 
Permission denied, please try again.
davem@master.kernel.org's password: 
>From master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6
 * branch            master     -> FETCH_HEAD
Already up-to-date.
davem@sunset:~/src/GIT/net-next-2.6$ 

Also all of your patch emails went out with the actual SMTP
"From: " changed, so it looks as if the patch author actually
sent those patch emails.

That's not what it should look like, the top level From: should
be you, and at the top of the commit message body there should
be another "From: " line demarking the patch author.
