From: "Gregory Haskins" <ghaskins@novell.com>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Thu, 06 Aug 2009 07:45:30 -0600
Message-ID: <4A7AA63A0200005A00051BE2@sinclair.provo.novell.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
 <20090806081955.GA9752@redhat.com>
 <4A7A8F7B0200005A00051B84@sinclair.provo.novell.com>
 <4A7AD29E.50800@redhat.com>
 <4A7A9C6B0200005A00051BB9@sinclair.provo.novell.com>
 <4A7ADE23.5010208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <alacrityvm-devel@lists.sourceforge.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, <kvm@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Avi Kivity" <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A7ADE23.5010208@redhat.com>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 8/6/2009 at  9:44 AM, in message <4A7ADE23.5010208@redhat.com>, Avi Kivity
<avi@redhat.com> wrote: 
> On 08/06/2009 04:03 PM, Gregory Haskins wrote:
>>> It's true that vbus is a separate project (in fact even virtio is
>>> completely separate from kvm).  Still I think it would be of interest to
>>> many kvm@ readers.
>>>      
>>
>> Well, my goal was to not annoy KVM readers. ;)  So if you feel as though 
> there is benefit to having all of KVM CC'd and I won't be annoying everyone, 
> I see no problem in cross posting.
>>    
> 
> I can only speak for myself, I'm interested in this project

In that case, the best solution is probably to have you (and anyone else interested) to sign up, then:

https://lists.sourceforge.net/lists/listinfo/alacrityvm-devel
https://lists.sourceforge.net/lists/listinfo/alacrityvm-users


> (though still rooting for virtio).

Heh...not to belabor the point to death, but virtio is orthogonal (you keep forgetting that ;).

Its really the vbus device-model vs the qemu device-model (and possibly vs the "in-kernel pci emulation" model that I believe Michael is working on).

You can run virtio on any of those three.

> 
>> Would you like to see all conversations, or just ones related to code (and, 
> of course, KVM relevant items)
> 
> I guess internal vbus changes won't be too interesting for most readers, 
> but new releases, benchmarks, and kvm-related stuff will be welcome on 
> the kvm list.

Ok, I was planning on that anyway.

Regards,
-Greg




