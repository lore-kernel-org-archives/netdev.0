From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] bnxt_en: New Broadcom ethernet driver.
Date: Thu, 22 Oct 2015 07:02:54 -0700 (PDT)
Message-ID: <20151022.070254.273038937417064562.davem@davemloft.net>
References: <1445413508-14932-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: prashant@broadcom.com, eddie.wai@broadcom.com,
	huangjw@broadcom.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54182 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754728AbbJVNq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 09:46:27 -0400
In-Reply-To: <1445413508-14932-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Wed, 21 Oct 2015 03:45:08 -0400

> Broadcom ethernet driver for the new family of NetXtreme-C/E
> ethernet devices.

Please don't have empty blank lines at the end of files, GIT even
warns about this.

davem@greenl8ke:~/src/GIT/net-next$ git am --signoff net-next-v4-bnxt_en-New-Broadcom-ethernet-driver..patch 
Applying: bnxt_en: New Broadcom ethernet driver.
/home/davem/src/GIT/net-next/.git/rebase-apply/patch:72: new blank line at EOF.
+
/home/davem/src/GIT/net-next/.git/rebase-apply/patch:8051: new blank line at EOF.
+
/home/davem/src/GIT/net-next/.git/rebase-apply/patch:8075: new blank line at EOF.
+
