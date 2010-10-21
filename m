From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] socket: localize functions
Date: Thu, 21 Oct 2010 03:12:12 -0700 (PDT)
Message-ID: <20101021.031212.189703483.davem@davemloft.net>
References: <20101018172729.68755c69@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60493
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755596Ab0JUKLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:11:49 -0400
In-Reply-To: <20101018172729.68755c69@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 18 Oct 2010 17:27:29 -0700

> A couple of functions in socket.c are only used there and
> should be localized.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
