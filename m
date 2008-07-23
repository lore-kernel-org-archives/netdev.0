From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] tun: Fix/rewrite packet filtering logic
Date: Tue, 22 Jul 2008 20:30:59 -0400
Message-ID: <48867BC3.3070506@garzik.org>
References: <1215852774-23974-1-git-send-email-maxk@qualcomm.com>	<4886703B.5090609@garzik.org> <20080722.171111.267353608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, rusty@rustcorp.com.au, netdev@vger.kernel.org,
	sjackman@gmail.com, linuxkernel@bristyle.com,
	virtualization@lists.linux-foundation.org, borntraeger@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47380 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207AbYGWAbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 20:31:07 -0400
In-Reply-To: <20080722.171111.267353608.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Tue, 22 Jul 2008 19:41:47 -0400
> 
>> looks mostly OK, but stuff like the above should be
>>
>> 	(void __user *) arg
>>
>> Did you check this with sparse (Documentation/sparse.txt)?
> 
> Jeff, I already added this particular patch to the tree
> a week or so ago.

Yeah, later on in my queue were the fixes.

	Jeff



