From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [ANNOUNCE]: First release of nftables
Date: Wed, 18 Mar 2009 15:43:26 +0530
Message-ID: <49C0C946.4090606@linux.vnet.ibm.com>
References: <49C078B6.4020603@trash.net> <87tz5r17ac.fsf@basil.nowhere.org> <49C0C74A.1090709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49C0C74A.1090709@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Andi Kleen wrote:
>   
>> Patrick McHardy <kaber@trash.net> writes:
>>   
>>     
>>> The userspace frontend is probably even more different to iptables than
>>> the kernel.
>>>     
>>>       
>> Are there plans to implement the existing iptables/ipchains/ipfw user
>> interfaces on top of nftables?
>>   
>>     
>
> I've thought about a "skin" in userspace to parse the iptables syntax
> and convert it to the new syntax. But the kernel won't have a compatibility
> interface and I'm not sure yet whether userspace will also be able to output
> iptables syntax. ipchains etc. definitely not.
>
>   
So, in that case if you are not going to provide a "skin" and that 
iptables will be removed eventually. wouldnt it break applications using 
iptables?
Sorry for such a basic question, but just curious.
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

