From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv10] vhost: vhost TX zero-copy support
Date: Mon, 18 Jul 2011 15:28:04 +0300
Message-ID: <20110718122804.GA5580@redhat.com>
References: <20110718105905.GA4786@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jj@chaosbits.net, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110718105905.GA4786@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2011 at 01:59:05PM +0300, Michael S. Tsirkin wrote:
> This adds experimental zero copy support in vhost-net,
> disabled by default.

Looks like there was a memory leak in the patch,
I'll address that and post a new version shortly.

-- 
MST
