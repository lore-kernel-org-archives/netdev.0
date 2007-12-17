From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER] xt_hashlimit : speedups hash_dst()
Date: Mon, 17 Dec 2007 13:38:23 +0100
Message-ID: <47666DBF.8060009@trash.net>
References: <4762F78B.80302@cosmosbay.com>	<4763AF65.4070200@gmail.com>	<4763B4CF.7010908@cosmosbay.com> <20071215.214219.129511362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, jarkao2@gmail.com,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20071215.214219.129511362.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sat, 15 Dec 2007 12:04:47 +0100
> 
>> I prefer to let admins chose their size, since it makes attacker life more 
>> difficult :)
>>
>> For example, I can tell you I have a server, were size is between 2.000.000 
>> and 3.500.000, I dont want to be forced to use 2097152
>>
>> A multiply is cheap, at least on current hardware.
> 
> I agree, and I see nothing wrong with Eric's patch and it
> should be merged ASAP.


I have it queued for 2.6.25 - would you like me to send it
for 2.6.24?


