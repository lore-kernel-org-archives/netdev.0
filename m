From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/5] net/ncsi: Fix AEN HNCDSC packet length
Date: Sat, 21 Oct 2017 01:56:57 +0100 (WEST)
Message-ID: <20171021.015657.257507348770037328.davem@davemloft.net>
References: <20171019024309.13628-1-sam@mendozajonas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sam@mendozajonas.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019024309.13628-1-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Date: Thu, 19 Oct 2017 13:43:05 +1100

> Correct the value of the HNCDSC AEN packet.
> Fixes: 7a82ecf4cfb85 "net/ncsi: NCSI AEN packet handler"
> 
> Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>

Applied.
