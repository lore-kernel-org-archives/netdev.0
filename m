From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 05 Dec 2005 17:56:54 -0500
Message-ID: <4394C5B6.8020301@psc.edu>
References: <200512022253.19029.a1426z@gawab.com> <200512031646.45332.a1426z@gawab.com> <4391E4FC.1040200@candelatech.com> <20051205140057.GC24764@tuxdriver.com> <20051205174010.GA14101@buici.com> <43947FEB.7020504@unfix.org> <4394BCD5.1060505@psc.edu> <4394C3D4.9050909@unfix.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marc Singer <elf@buici.com>, Ben Greear <greearb@candelatech.com>,
	Al Boldi <a1426z@gawab.com>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Jeroen Massar <jeroen@unfix.org>
In-Reply-To: <4394C3D4.9050909@unfix.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeroen Massar wrote:
> John Heffner wrote:
> 
>>Jeroen Massar wrote:
>>
>>>I wonder how many RFC's it violates. An interface must only answer ARP's
>>>on the interface that it is configured on, not anything else.
>>
>>Not true.  See RFC 1122, section 3.3.4.  The standard leaves this
>>decision up to the implementation, for good reason.
> 
> 
> RFC1122 is a document about multicast. ARP is broadcast see the very old
>  RFC826/STD0037. Multicast didn't even work on much of the hardware from
> the times that that document was written.

???  RFC 1122 is the Hosts Requirements RFC.  It applies to any host 
implementing IP.  Maybe you're thinking of 1112?

   -John
