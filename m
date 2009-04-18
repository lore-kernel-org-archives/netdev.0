From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH net next] myri10ge: fix compile error
Date: Sat, 18 Apr 2009 12:37:29 +0200
Message-ID: <49E9AD69.2030203@myri.com>
References: <49E8B8FD.8060100@myri.com> <20090417.154542.235044419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1977 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753685AbZDRKh0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Apr 2009 06:37:26 -0400
In-Reply-To: <20090417.154542.235044419.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Andrew Gallatin <gallatin@myri.com>
> Date: Fri, 17 Apr 2009 13:14:37 -0400
>
>   
>> A compilation error snuck into
>> 2d90b0aa3bc484189940444bcddcbe0ebbb53af5
>> due to an over-zealous indent script removing spaces around array
>> initialization ellipsis.  The attached patch fixes the myri10ge
>> compilation in net-next.
>>
>> Signed-off-by: Andrew Gallatin <gallatin@myri.com>
>>     
>
> It gives me great confidence in your work, seeing as you don't
> even type 'make' on the patches you send me.
>
> Sigh, applied...
>   


Apologies, it was entirely my fault here.

Brice

