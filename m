From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] VSOCK: Move af_vsock.h and vsock_addr.h to
 include/net
Date: Sat, 27 Jul 2013 22:14:20 -0700 (PDT)
Message-ID: <20130727.221420.1069834348574740989.davem@davemloft.net>
References: <1374745174-9859-1-git-send-email-asias@redhat.com>
	<728438598.12051834.1374853298283.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: asias@redhat.com, netdev@vger.kernel.org, dtor@vmware.com,
	grantr@vmware.com
To: acking@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53099 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831Ab3G1FOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jul 2013 01:14:21 -0400
In-Reply-To: <728438598.12051834.1374853298283.JavaMail.root@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy King <acking@vmware.com>
Date: Fri, 26 Jul 2013 08:41:38 -0700 (PDT)

>> This is useful for other VSOCK transport implemented outside the
>> net/vmw_vsock/ directory to use these headers.
>> 
>> Signed-off-by: Asias He <asias@redhat.com>
> 
> Acked-by: Andy King <acking@vmware.com>

Applied, thanks.
