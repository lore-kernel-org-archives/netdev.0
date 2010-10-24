From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] vmxnet3: remove set_flag_le{16,64} helpers
Date: Sun, 24 Oct 2010 15:43:07 -0700 (PDT)
Message-ID: <20101024.154307.35030082.davem@davemloft.net>
References: <1287720334-15469-1-git-send-email-harvey.harrison@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41247
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759263Ab0JXWmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 18:42:44 -0400
In-Reply-To: <1287720334-15469-1-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Thu, 21 Oct 2010 21:05:32 -0700

> It's easier to just annotate the constants as little endian types and set/clear
> the flags directly.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied.
