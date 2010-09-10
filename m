From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH 1/4] Add a new API to virtio-pci
Date: Fri, 10 Sep 2010 13:03:36 +0930
Message-ID: <201009101303.36638.rusty@rustcorp.com.au>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <201009092144.26484.rusty@rustcorp.com.au> <OF371A1B54.B0F5B4A1-ON65257799.00491939-65257799.004BBB65@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: anthony@codemonkey.ws, davem@davemloft.net, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <OF371A1B54.B0F5B4A1-ON65257799.00491939-65257799.004BBB65@in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2010 11:19:33 pm Krishna Kumar2 wrote:
> Rusty Russell <rusty@rustcorp.com.au> wrote on 09/09/2010 05:44:25 PM:
> > Ah, good point.  Move the queue index into the struct virtqueue?
> 
> Is it OK to move the queue_index from virtio_pci_vq_info
> to virtqueue? I didn't want to change any data structures
> in virtio for this patch, but I can do it either way.

Yep, it's logical to me.

Thanks!
Rusty.
