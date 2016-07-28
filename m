From: Hau <hau@realtek.com>
Subject: RE: [PATCH net 1/3] r8169:fix kernel log spam when set or get hardware wol setting.
Date: Thu, 28 Jul 2016 12:59:48 +0000
Message-ID: <80377ECBC5453840BA8C7155328B53770143B76A@RTITMBSV03.realtek.com.tw>
References: <1469637668-8751-1-git-send-email-hau@realtek.com>
 <1469637668-8751-2-git-send-email-hau@realtek.com>
 <20160727221804.GA3564@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160727221804.GA3564@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[...]
> Nit: you may directly use "struct device *d = &tp->pci_dev->dev;"
> 

I will do that on my next version patch.

Thanks.
------Please consider the environment before printing this e-mail.
