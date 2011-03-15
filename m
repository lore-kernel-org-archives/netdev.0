From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 0/2][pull request] Intel Wired LAN Driver Update
Date: Tue, 15 Mar 2011 14:51:25 -0700 (PDT)
Message-ID: <20110315.145125.260087059.davem@davemloft.net>
References: <1300168464-29546-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56869
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758354Ab1COVur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 17:50:47 -0400
In-Reply-To: <1300168464-29546-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 14 Mar 2011 22:54:22 -0700

> The following series contains a fix for timestamping and the
> addition of thermal sensor support for igb.
> 
> The following are changes since commit 0c0217b016ba8a970a6f6ab62ad0d858f39881ca:
>   net: dcbnl: Add IEEE app selector value definitions
> and are available in the git repository at:
>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master
> 
> Anders Berggren (1):
>   igb: fix hw timestamping
> 
> Carolyn Wyborny (1):
>   igb: Add messaging for thermal sensor events on i350 devices

Pulled, thanks Jeff.
