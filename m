From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tools: hv: Add a script for bonding synthetic
 and VF NICs
Date: Mon, 23 May 2016 13:53:31 -0700 (PDT)
Message-ID: <20160523.135331.946508716675076086.davem@davemloft.net>
References: <1463678618-26049-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	vkuznets@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463678618-26049-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Thu, 19 May 2016 10:23:38 -0700

> This example script creates bonding network devices based on synthetic NIC
> (the virtual network adapter usually provided by Hyper-V) and the matching
> VF NIC (SRIOV virtual function). So the synthetic NIC and VF NIC can
> function as one network device, and fail over to the synthetic NIC if VF is
> down.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Anything added like this to the tree should be distro neutral.

Furthermore, net-next is closed and no new features should be submitted
at this time.
