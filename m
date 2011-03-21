From: David Miller <davem@davemloft.net>
Subject: Re: [PULL net-2.6] vhost: cleanups and fixes
Date: Sun, 20 Mar 2011 19:08:00 -0700 (PDT)
Message-ID: <20110320.190800.193700848.davem@davemloft.net>
References: <20110317140403.GA16390@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, jasowang@redhat.com, krkumar2@in.ibm.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110317140403.GA16390@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 17 Mar 2011 16:04:04 +0200

> The following changes since commit 1fc050a13473348f5c439de2bb41c8e92dba5588:
> 
>   ipv4: Cache source address in nexthop entries. (2011-03-07 20:54:48 -0800)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net-next
> 
> Jason Wang (3):
>       vhost-net: check the support of mergeable buffer outside the receive loop
>       vhost-net: Unify the code of mergeable and big buffer handling
>       vhost: lock receive queue, not the socket
> 
> Krishna Kumar (1):
>       vhost: Cleanup vhost.c and net.c
> 
> Michael S. Tsirkin (2):
>       vhost: copy_from_user -> __copy_from_user
>       vhost-net: remove unlocked use of receive_queue

Pulled, thanks.
