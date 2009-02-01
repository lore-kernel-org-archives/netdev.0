From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 1/2] gianfar: Implement proper, per netdevice
 wakeup management
Date: Sun, 01 Feb 2009 00:54:25 -0800 (PST)
Message-ID: <20090201.005425.122181645.davem__379.489121451293$1233478585$gmane$org@davemloft.net>
References: <20090128203854.GA14693@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, afleming@freescale.com, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35581
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751710AbZBAIy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 03:54:28 -0500
In-Reply-To: <20090128203854.GA14693@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Wed, 28 Jan 2009 23:38:54 +0300

> This patch implements wakeup management for the gianfar driver.
> 
> The driver should set wakeup enable if WOL is enabled, so that
> phylib won't power off an attached PHY.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied.
