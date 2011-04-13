From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/4] [RFC rev2] Implement multiqueue (RX & TX) virtio-net
Date: Wed, 13 Apr 2011 21:52:38 +0530
Message-ID: <OF35E14C3D.C2D76CB8-ON65257871.0059A28B-65257871.0059C1D9@in.ibm.com>
References: <20110405150826.20501.39679.sendpatchset@krkumar2.in.ibm.com> <4DA5904B.9090006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, davem@davemloft.net,
	eric.dumazet@gmail.com, horms@verge.net.au, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:34379 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932926Ab1DMQU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 12:20:27 -0400
In-Reply-To: <4DA5904B.9090006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avi Kivity <avi@redhat.com> wrote on 04/13/2011 05:30:11 PM:

Hi Avi,

> > --------
> > 1. Reduce vectors for find_vqs().
> > 2. Make vhost changes minimal. For now, I have restricted the number of
> >     vhost threads to 4. This can be either made unrestricted; or if the
> >     userspace vhost works, it can be removed altogether.
> >
> > Please review and provide feedback. I am travelling a bit in the next
> > few days but will respond at the earliest.
>
> Do you have an update to the virtio-pci spec for this?

Not yet, will keep it in my TODO list.

thanks,

- KK

