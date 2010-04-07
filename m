From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH 1/3] A device for zero-copy based on KVM virtio-net.
Date: Wed, 7 Apr 2010 10:41:08 +0800
Message-ID: <97F6D3BD476C464182C1B7BABF0B0AF5C183234A@shzsmsx502.ccr.corp.intel.com>
References: <20100308112849.GI7482@redhat.com>
 <1270114038-5048-1-git-send-email-xiaohui.xin@intel.com>
 <20100401110841.GE3323@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"jdike@c2.user-mode-linux.org" <jdike@c2.user-mode-linux.org>,
	"yzhao81@gmail.com" <yzhao81@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100401110841.GE3323@redhat.com>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael,
 
>> Qemu needs a userspace write, is that a synchronous one or
>>asynchronous one?

>It's a synchronous non-blocking write.
Sorry, why the Qemu live migration needs the device have a userspace write?
how does the write operation work? And why a read operation is not cared here?

Thanks
Xiaohui
