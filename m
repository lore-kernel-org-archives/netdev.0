From: "hch@infradead.org" <hch@infradead.org>
Subject: Re: fanotify as syscalls
Date: Wed, 23 Sep 2009 17:56:58 -0400
Message-ID: <20090923215658.GA30096@infradead.org>
References: <20090912094110.GB24709@ioremap.net> <200909221731.34717.agruen@suse.de> <alpine.DEB.2.00.0909220836200.10460@makko.or.mcafeemobile.com> <200909230939.34003.tvrtko.ursulin@sophos.com> <20090923133232.5577688d@infradead.org> <1253721097.2890.3.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>,
	Tvrtko Ursulin <tvrtko.ursulin@sophos.com>,
	Davide Libenzi <davidel@xmailserver.org>,
	Andreas Gruenbacher <agruen@suse.de>,
	Jamie Lokier <jamie@shareable.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"alan@linux.intel.com" <alan@linux.intel.com>,
	"hch@infradead.org" <hch@infradead.org>
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751282AbZIWV5R@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1253721097.2890.3.camel@dhcp231-106.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 23, 2009 at 11:51:37AM -0400, Eric Paris wrote:
> And users would be left in a situation between choosing an LSM which
> actually does in provable ways increase security and using an AV
> scanner.

Sounds like a good thing, no?
