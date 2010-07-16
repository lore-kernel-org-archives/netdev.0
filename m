From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] vhost-net fixes
Date: Fri, 16 Jul 2010 12:57:51 -0700 (PDT)
Message-ID: <20100716.125751.173840884.davem@davemloft.net>
References: <20100716122530.GA29478@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100716122530.GA29478@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Fri, 16 Jul 2010 15:25:30 +0300

> David, please pull the following fixes for 2.6.35.
> Thanks!
> 
> The following changes since commit 91a72a70594e5212c97705ca6a694bd307f7a26b:
> 
>   net/core: neighbour update Oops (2010-07-14 18:02:16 -0700)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net
> 
> Michael S. Tsirkin (2):
>       vhost-net: avoid flush under lock
>       vhost: avoid pr_err on condition guest can trigger

Pulled, thanks!
