From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH v9 00/16] Provide a zero-copy method on KVM
 virtio-net.
Date: Mon, 13 Sep 2010 11:48:08 -0700
Message-ID: <1284403688.13351.1.camel@localhost.localdomain>
References: <1281086624-5765-1-git-send-email-xiaohui.xin@intel.com>
	 <1281489804.3391.23.camel@localhost.localdomain>
	 <1281490993.3391.25.camel@localhost.localdomain>
	 <1281506460.3391.42.camel@localhost.localdomain>
	 <1281509704.3391.45.camel@localhost.localdomain>
	 <20100903105233.GA32193@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100903105233.GA32193@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-09-03 at 13:52 +0300, Michael S. Tsirkin wrote:
> Could you look at the guest as well?

I just finished the patch built against the recent kernel. I will submit
perf data for both guest, host along with the patch.

Thanks
Shirley
