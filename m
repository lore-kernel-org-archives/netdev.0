From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH stable 3.11+] can: use private sk reference to detect
 originating socket
Date: Wed, 29 Jan 2014 22:25:44 +0100
Message-ID: <52E971D8.8000701@hartkopp.net>
References: <52E905C8.1060408@hartkopp.net>			 <1391007745.28432.36.camel@edumazet-glaptop2.roam.corp.google.com>			 <1391009406.28432.38.camel@edumazet-glaptop2.roam.corp.google.com>		 <1391010437.28432.39.camel@edumazet-glaptop2.roam.corp.google.com>		 <52E956E6.7090002@hartkopp.net>	 <1391025348.28432.63.camel@edumazet-glaptop2.roam.corp.google.com>	 <52E9675A.4070201@hartkopp.net> <52E96BDC.9070209@hartkopp.net> <1391029578.28432.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch2@gmail.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1391029578.28432.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29.01.2014 22:06, Eric Dumazet wrote:
> On Wed, 2014-01-29 at 22:00 +0100, Oliver Hartkopp wrote:
>> So here we are:
>>
>> Introduced can_create_echo_skb() which creates a skb which is properly
>> owned to be send back (echo'ed) into the network stack. 
>>
>> Regards,
>> Oliver
> 
> This seems much better ;)
> 

Great!

I'll give it some more testing on my Laptop and will send the patch with a
proper description tomorrow morning.

Thanks for your support fixing this issue!

Regards,
Oliver

