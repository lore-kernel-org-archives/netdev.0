From: John Eaglesham <linux@8192.net>
Subject: Re: [PATCH v6] bonding support for IPv6 transmit hashing
Date: Mon, 02 Jul 2012 22:38:05 -0700
Message-ID: <4FF2853D.9070707@8192.net>
References: <eb20e8f67e6aad94c233219e058c3e793ed755cb.1341167171.git.linux@8192.net> <18390.1341272010@death.nxdomain> <4FF27CA0.7030708@8192.net> <20120702.221425.418792617776598841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp171.dfw.emailsrvr.com ([67.192.241.171]:38221 "EHLO
	smtp171.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793Ab2GCFiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 01:38:06 -0400
In-Reply-To: <20120702.221425.418792617776598841.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/2/2012 10:14 PM, David Miller wrote:
> From: John Eaglesham <linux@8192.net>
> Date: Mon, 02 Jul 2012 22:01:20 -0700
>
>> I replaced the mixed tabs and spaces with all tabs when I updated that
>> function, but in retrospect the tabs and spaces were likely
>> intentional. I will revert.
>
> They were.  Don't change existing coding style unless you are certain
> it is wrong.
>
> Besides any such changes are completely outside of the scope of
> the changes you are making, so you should have left them out in
> any event.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Should the indents in the code I am adding follow the style guide and 
use only tabs, or follow the style already present and mix spaces and 
tabs for indentation?

Thanks,
John
