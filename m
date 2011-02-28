From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/3] [RFC] Implement multiqueue (RX & TX) virtio-net
Date: Mon, 28 Feb 2011 21:05:57 +0530
Message-ID: <OF1251EB54.5DB3E167-ON65257845.00557A9F-65257845.00558DAA@in.ibm.com>
References: <20110228063427.24908.63561.sendpatchset@krkumar2.in.ibm.com> <20110228073514.GA28006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, horms@verge.net.au,
	kvm@vger.kernel.org, netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110228073514.GA28006@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 02/28/2011 01:05:15 PM:

> > This patch series is a continuation of an earlier one that
> > implemented guest MQ TX functionality.  This new patchset
> > implements both RX and TX MQ.  Qemu changes are not being
> > included at this time solely to aid in easier review.
> > Compatibility testing with old/new combinations of qemu/guest
> > and vhost was done without any issues.
> >
> > Some early TCP/UDP test results are at the bottom of this
> > post, I plan to submit more test results in the coming days.
> >
> > Please review and provide feedback on what can improve.
> >
> > Thanks!
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
>
>
> To help testing, could you post the qemu changes separately please?

Thanks Michael for your review and feedback. I will send the qemu
changes and respond to your comments tomorrow.

Thanks,

- KK

