From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH net-next] myri10ge: fix indentation
Date: Mon, 24 Nov 2008 23:52:47 +0100
Message-ID: <492B303F.3080502@myri.com>
References: <49295DFD.9050609@myri.com> <20081124.144357.65741555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1865 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752508AbYKXWxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 17:53:10 -0500
In-Reply-To: <20081124.144357.65741555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Brice Goglin <brice@myri.com>
> Date: Sun, 23 Nov 2008 14:43:25 +0100
>
>   
>> Bring the indentation in line with the output of the Lindent script.
>>
>> Signed-off-by: Brice Goglin <brice@myri.com>
>>     
>
> Please don't blindly apply tools like this.
>   

We apply indent because our internal CVS contains some #ifdef'ery to
support old kernels and we want to cleanup the mess before submitting
patches. I'll see if I can hack something here to make this struct
initializer match your will.

Brice

