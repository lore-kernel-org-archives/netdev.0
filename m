From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: wireless-2.6 queue opened
Date: Thu, 03 Jun 2004 00:17:55 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40BEA673.8080301@pobox.com>
References: <40BE9ED8.9020505@pobox.com> <20040602211038.287628ac.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	jkmaline@cc.hut.fi, james.p.ketrenos@intel.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265495AbUFCESP@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040602211038.287628ac.davem@redhat.com>
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 02 Jun 2004 23:45:28 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>Given that there are at least 3 complete wireless stacks (or 
>>thereabouts) floating about for Linux, I picked one that I felt had the 
>>best chance of being _evolved_ into a nice, clean, generic wireless 
>>stack:  HostAP.
> 
> 
> Even though I authored one of the "other" stacks, I'm totally fine
> with this choice.  Mainly because I simply lack the time or resources
> to continue working on the stack I started.


Actually...   I want to use some of your stuff too.  :)  HostAP is a 
successful implementation, but your stuff was a good example of the glue 
needed to tie 802.11 tightly to the net stack.

HostAP still has some "its a separate driver" stuff it needs to get rid 
of, as it is made more generic.

	Jeff
