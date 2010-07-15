From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 1/1] netxen: fix for kdump
Date: Wed, 14 Jul 2010 17:55:44 -0700 (PDT)
Message-ID: <20100714.175544.104047399.davem@davemloft.net>
References: <1279020822-10419-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	rajesh.borundia@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38982
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757614Ab0GOAz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 20:55:28 -0400
In-Reply-To: <1279020822-10419-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Tue, 13 Jul 2010 04:33:42 -0700

> From: Rajesh Borundia <rajesh.borundia@qlogic.com>
> 
> When the crash kernel is loaded after crash, the device is in unknown state.
> So reset the device contexts prior to its creation in case of kdump,
> depending upon kernel parameter reset_devices.
> 
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>

Applied, thanks.
