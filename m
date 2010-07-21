From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Wed, 21 Jul 2010 11:50:23 -0700 (PDT)
Message-ID: <20100721.115023.69942880.davem@davemloft.net>
References: <201007211129.48288.leedom@chelsio.com>
	<43F901BD926A4E43B106BF17856F0755F184620A@orsmsx508.amr.corp.intel.com>
	<20100721.114851.200597269.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, shemminger@vyatta.com, andy@greyhouse.net,
	harald@redhat.com, bhutchings@solarflare.com, sassmann@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com, alexander.h.duyck@intel.com
To: gregory.v.rose@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100721.114851.200597269.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 21 Jul 2010 11:48:51 -0700 (PDT)

> You could do things like have the PF controller use the root filesystem
> ID label to construct the VF's MAC address, or something like that.

And here I of course mean the root filesystem of the guest the VF will
be given to.
