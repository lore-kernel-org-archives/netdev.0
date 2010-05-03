From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvtap: add ioctl to modify vnet header size
Date: Mon, 03 May 2010 01:00:16 -0700 (PDT)
Message-ID: <20100503.010016.113721762.davem@davemloft.net>
References: <20100502.233232.66719719.davem@davemloft.net>
	<20100502.233439.77341308.davem@davemloft.net>
	<20100503075511.GA8298@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, sri@us.ibm.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlstevens@us.ibm.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100503075511.GA8298@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 3 May 2010 10:55:11 +0300

> On Sun, May 02, 2010 at 11:34:39PM -0700, David Miller wrote:
>> What tree is this supposed to build under?  Certinaly not net-2.6
>> or net-next-2.6
> 
> The reason is it needs to be applied on top of the patch that adds the
> same header to tun that you acked.  I put this in patch description:
>> I plan to merge both patches through vhost tree together
>> with mergeable buffer support. Comments?
> In other words, this will be included in a pull request that I
> intend to send out shortly.

works for me:

Acked-by: David S. Miller <davem@davemloft.net>
