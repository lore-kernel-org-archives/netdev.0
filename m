From: John <linux@8192.net>
Subject: Re: [PATCH V2 1/2] bonding support for IPv6 transmit hashing
Date: Fri, 27 Apr 2012 14:21:03 -0700
Message-ID: <4F9B0DBF.9030201@8192.net>
References: <4F8E0A8D.9080803@8192.net> <22560.1335307907@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp141.dfw.emailsrvr.com ([67.192.241.141]:43656 "EHLO
	smtp141.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559Ab2D0VVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 17:21:01 -0400
In-Reply-To: <22560.1335307907@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Jay. It was against Linux 3.3.0. I will update my patch and re-post.

John

On 4/24/2012 3:51 PM, Jay Vosburgh wrote:
> John<linux@8192.net>  wrote:
>
> 	In principle, I think this is a good idea, but the patch has
> some (mostly style) issues, and does not apply to net-next (you don't
> say what tree it is based on).
>
> 	Can you address the comments noted below, and repost against the
> current net-next?
>
