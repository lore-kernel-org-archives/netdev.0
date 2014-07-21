From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Mon, 21 Jul 2014 11:18:51 +0200
Message-ID: <20140721091851.GA28171@aepfle.de>
References: <1405680903-28176-1-git-send-email-yuezha@microsoft.com>
 <CAFLxGvxQU_z+mChHsNSu9VZEdXrU+RU75k6H18uKbdAj2TKD5g@mail.gmail.com>
 <DC7803B42427924284F2D5252E076A3B44769DCA@SINEX14MBXC416.southpacific.corp.microsoft.com>
 <53CCB944.8090709@nod.at>
 <DC7803B42427924284F2D5252E076A3B4476A363@SINEX14MBXC416.southpacific.corp.microsoft.com>
 <53CCCCAD.7080906@nod.at>
 <DC7803B42427924284F2D5252E076A3B4476A479@SINEX14MBXC416.southpacific.corp.microsoft.com>
 <53CCD6F2.6020909@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Yue Zhang (OSTC DEV)" <yuezha@microsoft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	KY Srinivasan <kys@microsoft.com>,
	Thomas Shao <huishao@microsoft.com>,
	Dexuan Cui <decui@microsoft.com>
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53CCD6F2.6020909@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 21, Richard Weinberger wrote:

> My concern is that 10 seconds is maybe not a the right choice.
> (As we cannot know all implementations)

Until someone reports an issue with it, 10 is fine. Just like 20 or 666.

Olaf
