From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 3/3] netxen: fix firmware type check
Date: Tue, 08 Dec 2009 20:38:43 -0800 (PST)
Message-ID: <20091208.203843.245814557.davem@davemloft.net>
References: <1260051836-14425-1-git-send-email-amit.salecha@qlogic.com>
	<1260051836-14425-4-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	dhananjay@netxen.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37960
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756798AbZLIEig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:38:36 -0500
In-Reply-To: <1260051836-14425-4-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Sat,  5 Dec 2009 14:23:56 -0800

> From: Dhananjay Phadke <dhananjay@netxen.com>
> 
> Unified firmware image may not contain MN type of firmware.
> Driver should fall back to NOMN firmware type instead
> of going to flash.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
