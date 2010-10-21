From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL net-2.6] vhost-net: access_ok fix
Date: Thu, 21 Oct 2010 01:08:59 -0700 (PDT)
Message-ID: <20101021.010859.71110203.davem@davemloft.net>
References: <20101019145901.GA16025@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101019145901.GA16025@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 19 Oct 2010 16:59:01 +0200

> David,
> Not sure if it's too late for 2.6.36 - in case it's not, the following tree
> includes a last minute bugfix for vhost-net, found by code inspection.
> It is on top of net-2.6.
> Thanks!
> 
> The following changes since commit b0057c51db66c5f0f38059f242c57d61c4741d89:
> 
>   tg3: restore rx_dropped accounting (2010-10-11 16:06:24 -0700)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net

Even though it's too late, I've pulled this.
