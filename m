From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 3/8] macb: convert printk to pr_ and friends
Date: Fri, 11 Mar 2011 13:53:38 +0100
Message-ID: <20110311125338.GM9351@game.jcrosoft.org>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
 <1299751843-9743-4-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	nicolas.ferre@atmel.com
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 64.mail-out.ovh.net ([91.121.185.65]:33173 "HELO
	64.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753878Ab1CKM7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 07:59:08 -0500
Content-Disposition: inline
In-Reply-To: <1299751843-9743-4-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10:10 Thu 10 Mar     , Jamie Iles wrote:
> macb is already using the dev_dbg() and friends helpers so use pr_foo()
> along with a pr_fmt() definition to make the printing a little cleaner.
> 
> Signed-off-by: Jamie Iles <jamie@jamieiles.com>
Acked-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>

Best Regards,
J.
