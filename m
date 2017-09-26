From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnxt_en: Remove redundant unlikely()
Date: Tue, 26 Sep 2017 10:23:19 -0700 (PDT)
Message-ID: <20170926.102319.619531094304484211.davem@davemloft.net>
References: <20170926131226.8423-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael.chan@broadcom.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60580 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965047AbdIZRXU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 13:23:20 -0400
In-Reply-To: <20170926131226.8423-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 26 Sep 2017 15:12:26 +0200

> IS_ERR() already implies unlikely(), so it can be omitted.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
