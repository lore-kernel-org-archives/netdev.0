From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: vhost mergeable buffers guest's cgroup
Date: Wed, 28 Jul 2010 04:27:35 +0300
Message-ID: <20100728012735.GA23243@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>, Li Zefan <lizf@cn.fujitsu.com>,
	dlstevens@us.ibm.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sridhar, David,
I pushed a mergeable buffers patchset on my vhost-net-next branch,
on top of the threading changes.
 
This is a minimal patch, which in my testing has zero impact on
non-mergeable path.

Please give this a spin and let me know.

Thanks!

-- 
MST
