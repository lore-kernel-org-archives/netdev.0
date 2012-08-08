From: Venu Byravarasu <vbyravarasu@nvidia.com>
Subject: What is the significance of coherent_dma_mask?
Date: Wed, 8 Aug 2012 09:28:17 +0530
Message-ID: <5021E3D8.3010503@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<swarren@nvidia.com>
To: <gregkh@linuxfoundation.org>, <rdunlap@xenotime.net>,
	<lars@metafoo.de>, <grant.likely@secretlab.ca>, <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Some of the USB drivers are setting coherent_dma_mask & many others are 
not doing it.
 From the description present in the comment beside this field in 
device.h, I could not understand its real significance.

Can some one plz let me know its real need and use case where it is 
mandatory to use it?

Thanks,
Venu
