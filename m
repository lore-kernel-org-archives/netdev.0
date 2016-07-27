From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v18 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Wed, 27 Jul 2016 09:20:36 +0000
Message-ID: <CO2PR03MB2182653F8FADC3FEA594B893BF0F0@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <CO2PR03MB2182FD2D8AED7FFC7608510FBF0B0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160725.173701.1282720667210726281.davem@davemloft.net>
 <CO2PR03MB2182D011056AA151CCEF4EFFBF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160725.213822.1745865660912873332.davem@davemloft.net>
 <CO2PR03MB218254B70CBD052069CDEB4FBF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <CO2PR03MB218232A5C9AE5DBD2AB0374ABF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160726095637.GC8749@unicorn.suse.cz>
 <CO2PR03MB218213882E0C6F9B00E62683BF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"dave.scott@docker.com" <dave.scott@docker.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"joe@perches.com" <joe@perches.com>,
	"rolf.neugebauer@docker.com" <rolf.neugebauer@docker.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CO2PR03MB218213882E0C6F9B00E62683BF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Dexuan Cui
> Sent: Tuesday, July 26, 2016 21:22
> ...
> This is because, the design of AF_HYPERV in the Hyper-V host side is
> suboptimal IMHO (the current host side design requires the least
> change in the host side, but it makes my life difficult. :-(  It may
> change in the future, but luckily we have to live with it at present):
BTW, sorry for my typo: "luckily" should be "unluckily".

Thanks,
-- Dexuan
