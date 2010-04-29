From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC][PATCH v4 05/18] Add a function to indicate if device use
 	external buffer.
Date: Thu, 29 Apr 2010 09:38:04 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D7902DF999655@shsmsx502.ccr.corp.intel.com>
References: <1272187206-18534-1-git-send-email-xiaohui.xin@intel.com>
 	<1272187206-18534-2-git-send-email-xiaohui.xin@intel.com>
 	<1272187206-18534-3-git-send-email-xiaohui.xin@intel.com>
 	<1272187206-18534-4-git-send-email-xiaohui.xin@intel.com>
 	<1272187206-18534-5-git-send-email-xiaohui.xin@intel.com>
 <t2z412e6f7f1004250235ib1002b3doe604d786dadefaa5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <t2z412e6f7f1004250235ib1002b3doe604d786dadefaa5@mail.gmail.com>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static int dev_is_mpassthru(struct net_device *dev)
>
>bool return value should be better here.
>
>-- 
>Regards，
>Changli Gao(xiaosuo@gmail.com)

Thanks, would fix that.

Thanks
Xiaohui
