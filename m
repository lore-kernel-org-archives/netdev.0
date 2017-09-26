From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ldmvsw: Remove redundant unlikely()
Date: Tue, 26 Sep 2017 10:23:31 -0700 (PDT)
Message-ID: <20170926.102331.1561509490458048771.davem@davemloft.net>
References: <20170926131415.8649-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shannon.nelson@oracle.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60600 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965047AbdIZRXc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 13:23:32 -0400
In-Reply-To: <20170926131415.8649-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 26 Sep 2017 15:14:15 +0200

> IS_ERR() already implies unlikely(), so it can be omitted.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
