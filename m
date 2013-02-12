From: Peter Lieven <pl@dlhnet.de>
Subject: Re: [Qemu-devel] tap devices not receiving packets from a bridge
Date: Tue, 12 Feb 2013 11:11:45 +0100
Message-ID: <D40E1487-27E9-40B3-B007-085B432E5600@dlhnet.de>
References: <50AE36E0.8000307@dlhnet.de> <20121123070211.GC22787@stefanha-thinkpad.hitronhub.home> <E85C6011-548D-4507-A776-1028DD3E3515@dlhnet.de> <20121123110146.GC7051@redhat.com> <50FE5607.9020405@dlhnet.de> <20130123100312.GA8108@redhat.com> <5119E9DC.3000505@dlhnet.de> <20130212090850.GB22029@redhat.com> <056542E4-18E4-4C9F-AC96-60661768D6AF@dlhnet.de> <511A0DBB.7080907@msgid.tls.msk.ru> <20130212095422.GA23270@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	Stefan Hajnoczi <stefanha@gmail.com>, qemu-devel@nongnu.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ssl.dlhnet.de ([91.198.192.8]:44901 "EHLO ssl.dlh.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932672Ab3BLKLr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 05:11:47 -0500
In-Reply-To: <20130212095422.GA23270@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Am 12.02.2013 um 10:54 schrieb "Michael S. Tsirkin" <mst@redhat.com>:

> On Tue, Feb 12, 2013 at 01:39:07PM +0400, Michael Tokarev wrote:
>> 12.02.2013 13:10, Peter Lieven wrote:
>> []
>> 
>> Guys, can we please trim the excessive quoting just a bit? ;)
>> 
>>>>> If have set this option for 2 weeks now and not seen this problem again.
>>>>> How does this flag work with the recently added tap multiqueue support?
>> 
>>>> This will be the only option in 3.8.
>> 
>>> Ok, but wouldn`t it be good to set it in qemu for kernels <3.8?
>> 
>> I'd say for kernels without mq support, not for <3.8, right? :)
>> 
>> Thanks,
>> 
>> /mjt
> 
> It's harmless to always set this flag, on 3.8 it does nothing.

And kernels <3.8 do not have multi queue support?

Peter

> 
> -- 
> MST
