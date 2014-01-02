From: David Miller <davem@davemloft.net>
Subject: Re: [net-next bugfix] tun, rfs: fix the incorrect hash value
Date: Thu, 02 Jan 2014 02:41:55 -0500 (EST)
Message-ID: <20140102.024155.879200952880307639.davem@davemloft.net>
References: <1388640268-25575-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, therbert@google.com,
	wuzhy@linux.vnet.ibm.com
To: zwu.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbaABHl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 02:41:59 -0500
In-Reply-To: <1388640268-25575-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <zwu.kernel@gmail.com>
Date: Thu,  2 Jan 2014 13:24:28 +0800

> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
> The code incorrectly save the queue index as the hash, so this patch
> is fixing it with the hash received in the stack receive path.
> 
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Applied, thanks.
