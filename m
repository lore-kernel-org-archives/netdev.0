From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL net-2.6] vhost-net: rcu fixup
Date: Sun, 28 Nov 2010 11:27:47 -0800 (PST)
Message-ID: <20101128.112747.35051709.davem@davemloft.net>
References: <20101125122301.GA15990@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20101125122301.GA15990@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 25 Nov 2010 14:23:01 +0200

> Please merge the following fix for 2.6.36.
> Thanks!
> 
> The following changes since commit a27e13d370415add3487949c60810e36069a23a6:
> 
>   econet: fix CVE-2010-3848 (2010-11-24 11:51:47 -0800)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net
> 
> Michael S. Tsirkin (1):
>       vhost/net: fix rcu check usage
> 

Pulled, thanks Michael.
