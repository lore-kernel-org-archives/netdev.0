From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: vhost mergeable buffers guest's cgroup
Date: Wed, 28 Jul 2010 04:31:36 +0300
Message-ID: <20100728013136.GA23358@redhat.com>
References: <20100728012735.GA23243@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>, Li Zefan <lizf@cn.fujitsu.com>,
	dlstevens@us.ibm.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100728012735.GA23243@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 28, 2010 at 04:27:35AM +0300, Michael S. Tsirkin wrote:
> Sridhar, David,
> I pushed a mergeable buffers patchset on my vhost-net-next branch,
> on top of the threading changes.
>  
> This is a minimal patch, which in my testing has zero impact on
> non-mergeable path.
> 
> Please give this a spin and let me know.
> 
> Thanks!

The userspace bits can be found on my qemu-kvm tree at kernel.org,
branch vhost_mergeable.
Please use these for testing.

> -- 
> MST
