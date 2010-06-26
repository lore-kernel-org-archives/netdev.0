From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/6] cnic: Unify kcq allocation for all
 devices.
Date: Fri, 25 Jun 2010 21:07:19 -0700 (PDT)
Message-ID: <20100625.210719.91322533.davem@davemloft.net>
References: <1277427522-17306-1-git-send-email-mchan@broadcom.com>
	<1277427522-17306-2-git-send-email-mchan@broadcom.com>
	<1277427522-17306-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38372
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751035Ab0FZEHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:07:06 -0400
In-Reply-To: <1277427522-17306-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 24 Jun 2010 17:58:39 -0700

> By creating a common data stucture kcq_info for all devices, the kcq
> (kernel completion queue) for all devices can be allocated by common
> code.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
