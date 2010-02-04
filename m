From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] qlge: removing unreachable block of code
Date: Thu, 04 Feb 2010 15:42:52 -0800 (PST)
Message-ID: <20100204.154252.21126918.davem@davemloft.net>
References: <48284d15bf68cb154cf3948f3fd0b8ea11981ff3.1265314112.git.root@sanx1002.austin.ibm.com>
	<20100204231130.GD9938@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46786
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932660Ab0BDXmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 18:42:39 -0500
In-Reply-To: <20100204231130.GD9938@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Thu, 4 Feb 2010 15:11:30 -0800

> On Thu, Feb 04, 2010 at 12:11:18PM -0800, leitao@linux.vnet.ibm.com wrote:
>> Currently the qlge_change_mtu() is never called if the new_mtu is
>> equal current MTU, due this condition on dev_set_mtu():
> 
> Both look good.  Thanks
> 
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Both patches applied, thanks everyone.
