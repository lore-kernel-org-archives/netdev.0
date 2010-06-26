From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/6] cnic: Restructure kcq processing.
Date: Fri, 25 Jun 2010 21:07:33 -0700 (PDT)
Message-ID: <20100625.210733.45884905.davem@davemloft.net>
References: <1277427522-17306-2-git-send-email-mchan@broadcom.com>
	<1277427522-17306-3-git-send-email-mchan@broadcom.com>
	<1277427522-17306-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38376
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751611Ab0FZEHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:07:20 -0400
In-Reply-To: <1277427522-17306-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 24 Jun 2010 17:58:40 -0700

> By doing more work in the common function cnic_get_kcqes(), and
> making full use of the kcq_info structure.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
