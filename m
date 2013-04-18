From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV
 probes
Date: Thu, 18 Apr 2013 11:19:30 -0700
Message-ID: <20130418181930.GF9897@mtj.dyndns.org>
References: <20130411190408.GM17641@mtj.dyndns.org>
 <20130411191717.GB25515@redhat.com>
 <20130411192005.GN17641@mtj.dyndns.org>
 <20130411203053.GC25515@redhat.com>
 <20130411204104.GC11956@mtj.dyndns.org>
 <516AA80F.7040505@mellanox.com>
 <20130414134339.GA3050@htj.dyndns.org>
 <20130418083347.GA16526@redhat.com>
 <517007F0.4060000@mellanox.com>
 <20130418135458.GC20862@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130418135458.GC20862@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 18, 2013 at 04:54:58PM +0300, Michael S. Tsirkin wrote:
> Tejun, what do you say my patch is used for 3.9,
> and we can revisit for 3.10.
> The release is almost here.
> If yes please send your Ack.

Yeap, let's do that.

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
