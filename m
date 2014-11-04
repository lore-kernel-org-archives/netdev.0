From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] drivers: net: xgene: Fix crash for backward
 compatibility
Date: Tue, 04 Nov 2014 17:09:20 -0500 (EST)
Message-ID: <20141104.170920.1468894786590700012.davem@davemloft.net>
References: <1415044796-5081-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, patches@apm.com,
	kchudgar@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59831 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbaKDWJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 17:09:24 -0500
In-Reply-To: <1415044796-5081-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Mon,  3 Nov 2014 11:59:53 -0800

> This patch set fixes the following issues that were reported during regression.
> 
> Patch 1,2 : Adds backward compatibility with the older firmware (<= 1.13.28).
> Patch 3   : Use separate hardware resources (descriptor ring, prefetch buffer)
> 	   that are not shared with the firmware

Series applied, thanks.
