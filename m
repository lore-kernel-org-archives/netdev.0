From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v8 0/4] net: Add Keystone NetCP ethernet driver support
Date: Fri, 30 Jan 2015 00:49:38 +0100
Message-ID: <1824888.BBQhuVu1zR@wuerfel>
References: <1421367007-19744-1-git-send-email-m-karicheri2@ti.com> <15828198.gHAJTouZOU@wuerfel> <54CAC038.9000009@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "Balbi, Felipe" <balbi@ti.com>, mugunthanvnm@ti.com,
	David Miller <davem@davemloft.net>, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54CAC038.9000009@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 29 January 2015 18:20:24 Murali Karicheri wrote:
> 
> I have just posted a patch to nedev list to address this issue. Please 
> review and let me know your comments. This also require some additional 
> fixes in drivers/soc/ti/ to build them as modules as well. Santosh has 
> queued them against next merge window.

Ok, thanks for addressing this! As I wrote in reply to your patch, I'll
give it some extra build testing in random configurations.

	Arnd
