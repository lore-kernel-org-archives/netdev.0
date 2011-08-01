From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bna: HW Interface Init Update
Date: Mon, 01 Aug 2011 01:56:29 -0700 (PDT)
Message-ID: <20110801.015629.1512080453435229762.davem@davemloft.net>
References: <1311889767-9848-1-git-send-email-rmody@brocade.com>
	<1311889767-9848-2-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769Ab1HAI5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 04:57:31 -0400
In-Reply-To: <1311889767-9848-2-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Thu, 28 Jul 2011 14:49:27 -0700

> Change details:
>  - Split the hw interface into common and asic specific to support new asic
>    in the future.
>  - Fix bfa_ioc_ct_isr_mode_set() to also include the case that we are already
>    in the desired msix mode.
> 
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Queued up for net-next
