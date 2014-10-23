From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next 1/3] gianfar: Add flow control support flags
Date: Thu, 23 Oct 2014 12:36:34 +0300
Message-ID: <5448CC22.9000300@freescale.com>
References: <1414051077-4330-1-git-send-email-matei.pavaluca@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Matei Pavaluca <matei.pavaluca@freescale.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0118.outbound.protection.outlook.com ([207.46.100.118]:13329
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750799AbaJWJgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2014 05:36:48 -0400
In-Reply-To: <1414051077-4330-1-git-send-email-matei.pavaluca@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2014 10:57 AM, Matei Pavaluca wrote:
> From: Pavaluca Matei <matei.pavaluca@freescale.com>
>
> The phy device supports 802.3x flow control, but the specific flags are not set
> in the phy initialisation code. Flow control flags need to be added to the
> supported capabilities of the phydev by the driver.
>
> This is needed in order for ethtool to work ('ethtool -A' code checks for these
> flags)
>
> Signed-off-by: Pavaluca Matei <matei.pavaluca@freescale.com>

Acked-by: Claudiu Manoil <claudiu.manoil@freescale.com>
