From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Driver: Vmxnet3: set CHECKSUM_UNNECESSARY for IPv6
 packets
Date: Thu, 21 Apr 2016 15:29:23 -0400 (EDT)
Message-ID: <20160421.152923.1193193877419098358.davem@davemloft.net>
References: <1461201149-45583-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, heoj@vmware.com
To: skhare@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461201149-45583-1-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shrikrishna Khare <skhare@vmware.com>
Date: Wed, 20 Apr 2016 18:12:29 -0700

> For IPv6, if the device indicates that the checksum is correct, set
> CHECKSUM_UNNECESSARY.
> 
> Reported-by: Subbarao Narahari <snarahari@vmware.com>
> Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
> Signed-off-by: Jin Heo <heoj@vmware.com>

Applied.
