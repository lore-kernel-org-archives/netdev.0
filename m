From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] qlge: bugfix: Fix RX scaling values.
Date: Thu, 12 Feb 2009 16:39:17 -0800 (PST)
Message-ID: <20090212.163917.252923276.davem@davemloft.net>
References: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
	<1234360717-32194-6-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47168
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757948AbZBMAjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:39:24 -0500
In-Reply-To: <1234360717-32194-6-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Wed, 11 Feb 2009 05:58:36 -0800

> Receive packets were only scaling across 2 of the receive queues. The
> value was hardcoded to 2 instead of being based on how many rx queues
> were running.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
