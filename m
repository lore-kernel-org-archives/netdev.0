From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 10:21:40 -0600
Message-ID: <4B30F214.80206@codemonkey.ws>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:51197 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641AbZLVQVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 11:21:44 -0500
In-Reply-To: <200912221701.56840.bzolnier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/2009 10:01 AM, Bartlomiej Zolnierkiewicz wrote:
>> new e1000 driver is more superior in architecture and do the required
>> work to make the new e1000 driver a full replacement for the old one.
>>      
> Right, like everyone actually does things this way..
>
> I wonder why do we have OSS, old Firewire and IDE stacks still around then?
>    

And it's always a source of pain, isn't it.

>>> I also personally don't see a big problem in having another set of
>>> virtual drivers -- Linux already has plenty (vmware, xen, virtio, power,
>>> s390-vm, ...) and it's not that they would be a particular maintenance
>>> burden impacting the kernel core.
>>>        
> Exactly, I also don't see any problem here, especially since AlacrityVM
> drivers have much cleaner design / internal architecture than some of their
> competitors..
>    

Care to provide some actual objective argument to why it's better than 
what we already have?

Regards,

Anthony Liguori

