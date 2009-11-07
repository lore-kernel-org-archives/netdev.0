From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] qlge: Set PCIe reset type for EEH to
 fundamental.
Date: Fri, 06 Nov 2009 20:35:37 -0800 (PST)
Message-ID: <20091106.203537.81602387.davem@davemloft.net>
References: <1257529498-17459-1-git-send-email-ron.mercer@qlogic.com>
	<1257529498-17459-3-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46696
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760250AbZKGEfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 23:35:12 -0500
In-Reply-To: <1257529498-17459-3-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Fri,  6 Nov 2009 09:44:58 -0800

> This device requires a fundamental reset when recovering from EEH.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
