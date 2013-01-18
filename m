From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/12][pull request] Intel Wired LAN Driver
 Updates
Date: Fri, 18 Jan 2013 14:11:46 -0500 (EST)
Message-ID: <20130118.141146.902250219844894994.davem@davemloft.net>
References: <1358521487-28610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567Ab3ARTLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:11:48 -0500
In-Reply-To: <1358521487-28610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 18 Jan 2013 07:04:35 -0800

> This series contains updates to e1000e and igb.  Most notably is the
> added timestamp support in e1000e and additional software timestamp
> support in igb.  As well as, the added thermal data support and SR-IOV
> configuration support in igb.
> 
> v2- dropped the following patches from the previous 14 patch series
> because changes were requested from the community:
>   e1000e: add support for IEEE-1588 PTP
>   igb: Report L4 Rx hash via skb->l4_rxhash

Pulled, thanks Jeff.
