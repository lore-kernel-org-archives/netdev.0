From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/2][RFC] virtio_net: Add MAC fitler table support
Date: Sat, 10 Jan 2009 21:48:54 +1030
Message-ID: <200901102148.54962.rusty@rustcorp.com.au>
References: <1231351563.7109.130.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kvm <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1231351563.7109.130.camel@lappy>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 08 January 2009 04:36:03 Alex Williamson wrote:
> virtio_net: Add MAC fitler table support

Ah, I see.  You really want multiple mac addresses, not just multicast
filtering?

Anthony, you think a control channel?  We can add a virtqueue, but it seems like a lot of work...

Rusty.
