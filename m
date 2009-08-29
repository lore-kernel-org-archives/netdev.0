From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] cnic: Put rx/tx ring allocation in
 separate function.
Date: Fri, 28 Aug 2009 23:47:33 -0700 (PDT)
Message-ID: <20090828.234733.221912604.davem@davemloft.net>
References: <1251316163-9359-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58401
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751814AbZH2GrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 02:47:19 -0400
In-Reply-To: <1251316163-9359-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 26 Aug 2009 12:49:22 -0700

> This will allow the 10G iSCSI code to reuse the function.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
