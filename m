From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] mcast: net_device dev not used
Date: Mon, 07 Mar 2011 15:51:27 -0800 (PST)
Message-ID: <20110307.155127.191402576.davem@davemloft.net>
References: <1299275106-11513-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53350
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751344Ab1CGXuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 18:50:50 -0500
In-Reply-To: <1299275106-11513-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Fri,  4 Mar 2011 22:45:03 +0100

> ip6_mc_source(), ip6_mc_msfilter() as well as ip6_mc_msfget() declare
> and assign dev but do not use the variable afterwards.
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

Applied.
