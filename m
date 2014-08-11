From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: qlogic: qlcnic: Remove duplicate object
 file from Makefile
Date: Mon, 11 Aug 2014 12:44:50 -0700 (PDT)
Message-ID: <20140811.124450.1136585913391192232.davem@davemloft.net>
References: <1407699648-3500-1-git-send-email-rupran@einserver.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shahed.shaikh@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com,
	netdev@vger.kernel.org
To: rupran@einserver.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825AbaHKTov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 15:44:51 -0400
In-Reply-To: <1407699648-3500-1-git-send-email-rupran@einserver.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Ruprecht <rupran@einserver.de>
Date: Sun, 10 Aug 2014 21:40:48 +0200

> In the Makefile, qlcnic_minidump.o is included twice in the list of
> object files linked into qlcnic.o.
> 
> This change removes the superfluous include.
> 
> Signed-off-by: Andreas Ruprecht <rupran@einserver.de>

Applied, thanks.
