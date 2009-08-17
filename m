From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for	vbus_driver
 objects
Date: Mon, 17 Aug 2009 17:59:35 +0300
Message-ID: <4A897057.2050504@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A87C3B9.2040206@redhat.com> <4A896648.9040707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Gregory Haskins <ghaskins@novell.com>,
	kvm@vger.kernel.org, alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A896648.9040707@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/17/2009 05:16 PM, Gregory Haskins wrote:
>> My opinion is that this is a duplication of effort and we'd be better
>> off if everyone contributed to enhancing virtio, which already has
>> widely deployed guest drivers and non-Linux guest support.
>>
>> It may have merit if it is proven that it is technically superior to
>> virtio (and I don't mean some benchmark in some point in time; I mean
>> design wise).  So far I haven't seen any indications that it is.
>>
>>      
>
> The design is very different, so hopefully I can start to convince you
> why it might be interesting.
>    

We've been through this before I believe.  If you can point out specific 
differences that make venet outperform virtio-net I'll be glad to hear 
(and steal) them though.

-- 
error compiling committee.c: too many arguments to function

