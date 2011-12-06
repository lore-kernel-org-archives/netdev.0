From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] remove an outdated reference to T/TCP
Date: Tue, 06 Dec 2011 13:39:23 -0800
Message-ID: <4EDE8B8B.2000907@hp.com>
References: <20111206200005.836D529006DD@tardy> <20111206.151920.696192671128392379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:1862 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754352Ab1LFVjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:39:25 -0500
In-Reply-To: <20111206.151920.696192671128392379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2011 12:19 PM, David Miller wrote:
> From: Rick Jones<rick.jones2@hp.com>
> Date: Tue,  6 Dec 2011 12:00:05 -0800 (PST)
>
>>
>> Remove a particularly out of date bit of comment referring to T/TCP.
>>
>> Signed-off-by: Rick Jones<rick.jones2@hp.com>
>
> I think it should stay because it discusses the potential bad side
> effects of queueing any data that might be in the SYN.

How about just the sentence that mentioned T/TCP explicitly since T/TCP 
is most definitely no longer starting to be used?-)  The rest of it can 
be discussed when/if TCP Fast Open arrives :)

rick
