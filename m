From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH v4 05/18] Add a function to indicate if device use
 external buffer.
Date: Sun, 25 Apr 2010 02:51:54 -0700 (PDT)
Message-ID: <20100425.025154.152946070.davem@davemloft.net>
References: <1272187206-18534-4-git-send-email-xiaohui.xin@intel.com>
	<1272187206-18534-5-git-send-email-xiaohui.xin@intel.com>
	<t2z412e6f7f1004250235ib1002b3doe604d786dadefaa5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	jdike@linux.intel.com
To: xiaosuo@gmail.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <t2z412e6f7f1004250235ib1002b3doe604d786dadefaa5@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>
Date: Sun, 25 Apr 2010 17:35:01 +0800

> On Sun, Apr 25, 2010 at 5:19 PM,  <xiaohui.xin@intel.com> wrote:
>> +static int dev_is_mpassthru(struct net_device *dev)
> 
> bool return value should be better here.

Right.
