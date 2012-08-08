From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Wed, 08 Aug 2012 15:42:38 -0700 (PDT)
Message-ID: <20120808.154238.554070934649158940.davem@davemloft.net>
References: <1344326657-9376-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756875Ab2HHWmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 18:42:39 -0400
In-Reply-To: <1344326657-9376-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Date: Tue,  7 Aug 2012 01:04:14 -0700

> This series contains fixes to the e1000e and igb drivers.
> 
> The following are changes since commit 5d299f3d3c8a2fbc732b1bf03af36333ccec3130:
>   
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/ppwaskie/net master
> 
> Stefan Assmann (1):
>   igb: add delay to allow igb loopback test to succeed on 8086:10c9
> 
> Tushar Dave (2):
>   e1000e: NIC goes up and immediately goes down
>   e1000e: 82571 Tx Data Corruption during Tx hang recovery

Pulled, thanks a lot.
