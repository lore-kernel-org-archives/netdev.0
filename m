From: Tvrtko Ursulin <tvrtko.ursulin@sophos.com>
Subject: Re: fanotify as syscalls
Date: Wed, 23 Sep 2009 16:42:43 +0100
Message-ID: <200909231642.43563.tvrtko.ursulin@sophos.com>
References: <20090912094110.GB24709@ioremap.net> <200909230939.34003.tvrtko.ursulin@sophos.com> <20090923133232.5577688d@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Davide Libenzi <davidel@xmailserver.org>,
	Andreas Gruenbacher <agruen@suse.de>,
	Jamie Lokier <jamie@shareable.org>,
	Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"alan@linux.intel.com" <alan@linux.intel.com>,
	"hch@infradead.org" <hch@infradead.org>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090923133232.5577688d@infradead.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 September 2009 12:32:32 Arjan van de Ven wrote:
> On Wed, 23 Sep 2009 09:39:33 +0100
>
> Tvrtko Ursulin <tvrtko.ursulin@sophos.com> wrote:
> > Lived with it because there was no other option. We used LSM while it
> > was available for modules but then it was taken away.
>
> ... at which point you could have submitted your LSM module for
> inclusion... you'd be the first (and only?) Anti Virus vendor that
> would be in the mainline kernel.. speaking of competitive advantage,
> coming out of the box in all distributions.
>
> sadly this road hasn't been chosen....

It has, but since what we had wasn't acceptable the road was long and it 
turned into fanotify. Which is not only about anti-malware (hello Christoph) 
so I think this sub-thread is going off-topic.

Tvrtko
