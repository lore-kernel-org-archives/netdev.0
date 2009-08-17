From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for	vbus_driver
 objects
Date: Mon, 17 Aug 2009 18:18:08 +0300
Message-ID: <4A8974B0.8050604@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A87C3B9.2040206@redhat.com> <4A896648.9040707@gmail.com> <4A897057.2050504@redhat.com> <4A8972C3.30202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Gregory Haskins <ghaskins@novell.com>,
	kvm@vger.kernel.org, alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756205AbZHQPSd@vger.kernel.org>
In-Reply-To: <4A8972C3.30202@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/17/2009 06:09 PM, Gregory Haskins wrote:
>
>> We've been through this before I believe.  If you can point out specific
>> differences that make venet outperform virtio-net I'll be glad to hear
>> (and steal) them though.
>>
>>      
> You sure know how to convince someone to collaborate with you, eh?
>
>    

If I've offended you, I apologize.

> Unforunately, i've answered that question numerous times, but it
> apparently falls on deaf ears.
>    

Well, I'm sorry, I truly don't think I've had that question answered 
with specificity.  I'm really interested in it (out of a selfish desire 
to improve virtio), but the only comment I recall from you was to the 
effect that the virtio rings were better than ioq in terms of cache 
placement.

-- 
error compiling committee.c: too many arguments to function
