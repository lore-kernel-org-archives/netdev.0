From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v16 02/17]Add a new struct for device to manipulate
 external buffer.
Date: Fri, 10 Dec 2010 12:36:07 -0800 (PST)
Message-ID: <20101210.123607.35053296.davem@davemloft.net>
References: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1291187695.git.xiaohui.xin@intel.com>
	<fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1291187695.git.xiaohui.xin@intel.com>
	<38fbf05a450b34e939aa1b0f3a5126711990f0cc.1291187695.git.xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	herbert@gondor.apana.org.au, jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <38fbf05a450b34e939aa1b0f3a5126711990f0cc.1291187695.git.xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: xiaohui.xin@intel.com
Date: Wed,  1 Dec 2010 16:08:13 +0800

> From: Xin Xiaohui <xiaohui.xin@intel.com>
> 
>     Add a structure in structure net_device, the new field is
>     named as mp_port. It's for mediate passthru (zero-copy).
>     It contains the capability for the net device driver,
>     a socket, and an external buffer creator, external means
>     skb buffer belongs to the device may not be allocated from
>     kernel space.
> 
>     Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
>     Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
>     Reviewed-by: Jeff Dike <jdike@linux.intel.com>

Please eliminate whatever is causing this indentation of your
commit messages.

There should be no special indentation of the commit message.
