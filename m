From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/6] Add 10GbE support to APM X-Gene SoC ethernet
 driver
Date: Thu, 09 Oct 2014 18:56:44 -0400 (EDT)
Message-ID: <20141009.185644.1973399214870399180.davem@davemloft.net>
References: <1412826861-32208-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, patches@apm.com,
	kchudgar@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbaJIW4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 18:56:46 -0400
In-Reply-To: <1412826861-32208-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Wed,  8 Oct 2014 20:54:15 -0700

> Adding 10GbE support to APM X-Gene SoC ethernet driver.
> 
> v3: Address comments from v2
> * dtb: changed to use all-zeros for the mac address
> 
> v2: Address comments from v1
> * created preparatory patch to review before adding new functionality
> * dtb: updated to use tabs consistently
> 
> v1:
> * Initial version

This does not apply to my current tree, in particular the DT files
get rejects.
