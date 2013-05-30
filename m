From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] be2net: Mark checksum fail for IP fragmented
 packets
Date: Thu, 30 May 2013 16:58:32 -0700 (PDT)
Message-ID: <20130530.165832.1108219046305006002.davem@davemloft.net>
References: <506aab59-7a41-4b4f-97e6-35f587fe9705@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kalesh.purayil@emulex.com
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095Ab3E3X6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 19:58:33 -0400
In-Reply-To: <506aab59-7a41-4b4f-97e6-35f587fe9705@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Thu, 30 May 2013 14:25:56 +0530

> HW does not compute L4 checksum for IP Fragmented packets.
> 
> Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied.
