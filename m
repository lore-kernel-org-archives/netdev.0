From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v8 0/4] net: Add Keystone NetCP ethernet driver support
Date: Thu, 29 Jan 2015 23:00:59 +0100
Message-ID: <15828198.gHAJTouZOU@wuerfel>
References: <1421367007-19744-1-git-send-email-m-karicheri2@ti.com> <54C9654C.8030407@ti.com> <54CA6C20.5090301@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "Balbi, Felipe" <balbi@ti.com>, mugunthanvnm@ti.com,
	David Miller <davem@davemloft.net>, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54CA6C20.5090301@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 29 January 2015 12:21:36 Murali Karicheri wrote:
> 
> I think the solution is to make the cpsw_ale as a module and configured 
> through a Kconfig option. I am working on a fix for this now.
> 
> Similar fix is required for cpts.o. Currently we are not using this 
> module for Netcp, but soon this will be re-used. I have send a patch 
> that is already applied to net-next removing cpts.o for Netcp.
> 

Great, thanks a lot for the follow-up.

	Arnd
