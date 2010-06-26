From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/6] cnic: Further unify kcq handling code.
Date: Fri, 25 Jun 2010 21:07:46 -0700 (PDT)
Message-ID: <20100625.210746.57452338.davem@davemloft.net>
References: <1277427522-17306-3-git-send-email-mchan@broadcom.com>
	<1277427522-17306-4-git-send-email-mchan@broadcom.com>
	<1277427522-17306-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40843
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751843Ab0FZEHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:07:34 -0400
In-Reply-To: <1277427522-17306-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 24 Jun 2010 17:58:41 -0700

> This eliminates some of the duplicate code for the various devices
> that require the same basic kcq handling.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
