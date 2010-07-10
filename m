From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] qlcnic: Disable admin tools interface
 for VF driver mode
Date: Fri, 09 Jul 2010 18:02:09 -0700 (PDT)
Message-ID: <20100709.180209.115926690.davem@davemloft.net>
References: <alpine.OSX.2.00.1007091611371.44317@macintosh-2.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: anirban.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37980
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751868Ab0GJBBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 21:01:55 -0400
In-Reply-To: <alpine.OSX.2.00.1007091611371.44317@macintosh-2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Date: Fri, 9 Jul 2010 16:15:05 -0700

> 
> Non privileged (VF) driver will not be able to carry out any of the FW update,
> etc. operations. Disable the tools interface by not creating the sysfs nodes.
> 
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Applied.
