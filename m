From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bna: Remove Unnecessary CNA Check
Date: Mon, 01 Aug 2011 01:56:19 -0700 (PDT)
Message-ID: <20110801.015619.1813387727215729540.davem@davemloft.net>
References: <1311889767-9848-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602Ab1HAI5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 04:57:22 -0400
In-Reply-To: <1311889767-9848-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Thu, 28 Jul 2011 14:49:26 -0700

> Change details:
>  - ioc->cna is always set to 1 for eth functions, remove the check that
>    asserts IOC is in CNA mode in bfa_ioc_firmware_lock() and
>    bfa_ioc_firmware_unlock() in bfa_ioc_ct.c.
> 
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Queued up for net-next
