From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] pci: Add VPD parsing support
Date: Fri, 26 Feb 2010 04:13:37 -0800 (PST)
Message-ID: <20100226.041337.97803895.davem@davemloft.net>
References: <1267121962-6077-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbarnes@virtuousgeek.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37926
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935157Ab0BZMNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:13:19 -0500
In-Reply-To: <1267121962-6077-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 25 Feb 2010 10:19:15 -0800

> This patch adds code to help parse a device's VPD.  The bnx2 and tg3
> network drivers are modified as an example on how to use the API.  I
> believe the bnx2x driver will also use this API in the future.

Matt, once the PCI folks take your VPD interfaces and defines,
resubmit the network driver changes to me.

Thanks.
