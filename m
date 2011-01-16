From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] vmxnet3 fixes and enhancements
Date: Sat, 15 Jan 2011 21:21:26 -0800 (PST)
Message-ID: <20110115.212126.115922222.davem@davemloft.net>
References: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
To: sbhatewara@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shreyas N Bhatewara <sbhatewara@vmware.com>
Date: Fri, 14 Jan 2011 16:59:20 -0800

> The following series fixes bugs and enhances functionality in the
> vmxnet3 driver.
> 
> ---
> 
> Shreyas N Bhatewara (8):
>       vmxnet3: fix ring size update
>       vmxnet3: Preserve the MAC address configured by ifconfig
>       vmxnet3: Enable HW Rx VLAN stripping by default
>       vmxnet3: Provide required number of bytes in first SG buffer
>       vmxnet3: Make ethtool handlers multiqueue aware
>       vmxnet3: Disable napi in suspend, reenable in resume.
>       vmxnet3: Add locking for access to command register
>       vmxnet3: Dont allocate extra MSI-x vectors

All applied, thanks.
