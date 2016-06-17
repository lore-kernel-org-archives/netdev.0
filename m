From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/7] vmxnet3: upgrade to version 3
Date: Thu, 16 Jun 2016 22:37:27 -0700 (PDT)
Message-ID: <20160616.223727.1715535480635369736.davem@davemloft.net>
References: <1466099519-39322-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
To: skhare@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466099519-39322-1-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shrikrishna Khare <skhare@vmware.com>
Date: Thu, 16 Jun 2016 10:51:52 -0700

> vmxnet3 emulation has recently added several new features which includes
> support for new commands the driver can issue to emulation, change in
> descriptor fields etc. This patch series extends the vmxnet3 driver to
> leverage these new features.
> 
> Compatibility is maintained using existing vmxnet3 versioning mechanism as
> follows:
>  - new features added to vmxnet3 emulation are associated with new vmxnet3
>    version viz. vmxnet3 version 3.
>  - emulation advertises all the versions it supports to the driver.
>  - during initialization, vmxnet3 driver picks the highest version number
>  supported by both the emulation and the driver and configures emulation
>  to run at that version.
> 
> In particular, following changes are introduced:
 ... 

Series applied, thanks.
