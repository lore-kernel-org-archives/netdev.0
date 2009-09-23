From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: fanotify as syscalls
Date: Wed, 23 Sep 2009 13:32:32 +0200
Message-ID: <20090923133232.5577688d@infradead.org>
References: <20090912094110.GB24709@ioremap.net>
	<200909221731.34717.agruen@suse.de>
	<alpine.DEB.2.00.0909220836200.10460@makko.or.mcafeemobile.com>
	<200909230939.34003.tvrtko.ursulin@sophos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
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
To: Tvrtko Ursulin <tvrtko.ursulin@sophos.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <200909230939.34003.tvrtko.ursulin@sophos.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Sep 2009 09:39:33 +0100
Tvrtko Ursulin <tvrtko.ursulin@sophos.com> wrote:

> Lived with it because there was no other option. We used LSM while it
> was available for modules but then it was taken away. 

... at which point you could have submitted your LSM module for
inclusion... you'd be the first (and only?) Anti Virus vendor that
would be in the mainline kernel.. speaking of competitive advantage,
coming out of the box in all distributions.

sadly this road hasn't been chosen....



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
