From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next v5] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Tue, 28 Jan 2014 11:29:38 +0800
Message-ID: <52E72422.1030205@oracle.com>
References: <1390731147-2424-1-git-send-email-Annie.li@oracle.com> <52E63382.6090503@citrix.com> <20140127.130921.7056971883805642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: david.vrabel@citrix.com, wei.liu2@citrix.com,
	ian.campbell@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xen.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26629 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219AbaA1D3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 22:29:48 -0500
In-Reply-To: <20140127.130921.7056971883805642.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2014/1/28 5:09, David Miller wrote:
> From: David Vrabel <david.vrabel@citrix.com>
> Date: Mon, 27 Jan 2014 10:22:58 +0000
>
>> I think this should be applied to net (and tagged as a stable candidate)
>> rather than net-next as this fixes are very big resource leak.
> Then this subject line and commit message must be fixed to make it clear
> that this is a BUG fix, rather then just a "clean up".
>

I will post a new patch with correct subject and commit message.

Thanks
Annie
