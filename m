From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] include/linux/if_ether.h: Add #define ETH_P_LINK_CTL
 for HPNA and wlan local tunnel
Date: Thu, 06 Jan 2011 11:10:15 -0800 (PST)
Message-ID: <20110106.111015.104054729.davem@davemloft.net>
References: <1292298831.26970.263.camel@Joe-Laptop>
	<1294193234-804-1-git-send-email-henryp@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, brudley@broadcom.com, arend@broadcom.com,
	rvossen@broadcom.com, dowan@broadcom.com, netdev@vger.kernel.org
To: henryp@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60501
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751959Ab1AFTJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 14:09:44 -0500
In-Reply-To: <1294193234-804-1-git-send-email-henryp@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Henry Ptasinski" <henryp@broadcom.com>
Date: Tue, 4 Jan 2011 18:07:14 -0800

> Ethertype used by HPNA control protocols (LARQ, rate, link, etc) and by
> Broadcom wlan drivers for local signalling.
> 
> Signed-off-by: Henry Ptasinski <henryp@broadcom.com>

Applied, thanks.
