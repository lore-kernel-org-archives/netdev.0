From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: Re: [PATCH] drivers/net/phy/Kconfig: Let MDIO_BCM_UNIMAC depend on
 HAS_IOMEM
Date: Mon, 06 Oct 2014 21:05:13 +0800
Message-ID: <54329389.2050304@gmail.com>
References: <542FC3D9.4080607@gmail.com> <20141006.004646.685997864382345892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, richard@nod.at
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141006.004646.685997864382345892.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/6/14 12:46, David Miller wrote:
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> Date: Sat, 04 Oct 2014 17:54:33 +0800
> 
>> MDIO_BCM_UNIMAC needs HAS_IOMEM, so depend on it, the related error (
>> with allmodconfig under um):
>>
>>     MODPOST 1205 modules
>>   ERROR: "devm_ioremap" [drivers/net/phy/mdio-bcm-unimac.ko] undefined!
>>
>> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> 
> Applied, thanks.
> 

Thank you for your work.

-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
