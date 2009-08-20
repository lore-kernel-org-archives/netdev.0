From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Thu, 20 Aug 2009 15:12:05 +0300
Message-ID: <20090820121205.GC5448@redhat.com>
References: <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com> <4A8ACE1F.6020402@gmail.com> <20090818165139.GC19846@redhat.com> <4A8B8F4E.80207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Avi Kivity <avi@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754187AbZHTMNu@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A8B8F4E.80207@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 19, 2009 at 01:36:14AM -0400, Gregory Haskins wrote:
> >> So where is the problem here?
> > 
> > If virtio net in guest could be improved instead, everyone would
> > benefit.
> 
> So if I whip up a virtio-net backend for vbus with a PCI compliant
> connector, you are happy?

I'm currently worried about venet versus virtio-net guest situation, if
you drop it and switch to virtio net instead that issue's resolved.

I don't have an opinion on vbus versus pci, and I only speak for myself.

-- 
MST
