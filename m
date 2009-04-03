From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 3 Apr 2009 10:09:20 -0700
Message-ID: <20090403170920.GM18394@sequoia.sous-sol.org>
References: <49D469D2020000A100045FA1@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D4CB38.5030205@redhat.com> <49D4DA54.3090401@novell.com> <49D4DE82.5020306@redhat.com> <49D4F97F.6040507@novell.com> <49D5F669.1070502@redhat.com> <49D6240B.4080809@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Avi Kivity <avi@redhat.com>,
	Patrick Mullaney <pmullaney@novell.com>, anthony@codemonkey.ws,
	andi@firstfloor.org, herbert@gondor.apana.org.au,
	Peter Morreale <PMorreale@novell.com>, rusty@rustcorp.com.au,
	agraf@suse.de, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49D6240B.4080809@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Gregory Haskins (ghaskins@novell.com) wrote:
> Let me ask you this:  If you had a clean slate and were designing a
> hypervisor and a guest OS from scratch:  What would you make the bus
> look like?

Well, virtio did have a relatively clean slate. And PCI (as _one_
transport option) is what it looks like.  It's not the only transport
(as Avi already mentioned it works for s390, for example).

BTW, from my brief look at vbus, it seems pretty similar to xenbus.

thanks,
-chris
