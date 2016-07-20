From: Fengguang Wu <lkp@intel.com>
Subject: Re: [kbuild-all] [PATCH v17 net-next 1/1] hv_sock: introduce Hyper-V
 Sockets
Date: Wed, 20 Jul 2016 09:52:11 +0800
Message-ID: <20160720015211.GA20015@wfg-t540p.sh.intel.com>
References: <CO2PR03MB2182D860B8B31579770E3798BF330@CO2PR03MB2182.namprd03.prod.outlook.com>
 <201607200149.0W6994tY%fengguang.wu@intel.com>
 <CO2PR03MB218232E102F17C0E8B3B7764BF080@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Michal Kubecek <mkubecek@suse.cz>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	Dave Scott <dave.scott@docker.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"joe@perches.com" <joe@perches.com>,
	Rolf Neugebauer <rolf.neugebauer@docker.com>,
	"kbuild-all@01.org" <kbuild-all@01.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	Cathy Avery <cavery@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CO2PR03MB218232E102F17C0E8B3B7764BF080@CO2PR03MB2182.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, sorry for the noises!

>> >> net/hv_sock/af_hvsock.o: warning: objtool: hvsock_on_channel_cb()+0x1d:
>> function has unreachable instruction
>
>These warnings are all false alarms.
>
>Thanks,
>-- Dexuan
>_______________________________________________
>kbuild-all mailing list
>kbuild-all@lists.01.org
>https://lists.01.org/mailman/listinfo/kbuild-all
