From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] drivers: net: xgene: fix kbuild warnings
Date: Thu, 30 Apr 2015 22:30:28 -0400 (EDT)
Message-ID: <20150430.223028.1104963892034684806.davem@davemloft.net>
References: <1430435357-20679-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	fengguang.wu@intel.com, dan.carpenter@oracle.com, kchudgar@apm.com,
	patches@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257AbbEACao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 22:30:44 -0400
In-Reply-To: <1430435357-20679-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Thu, 30 Apr 2015 16:09:17 -0700

> Fixed the following kbuild warnings:
> 1. unused variable 'of_id'
> 2. buffer overflow 'ring_cfg' 5 <= 5
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>

Applied.
