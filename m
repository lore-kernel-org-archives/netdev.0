From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kaweth: remove obsolete debugging statements
Date: Wed, 07 Sep 2016 17:45:51 -0700 (PDT)
Message-ID: <20160907.174551.41509590097541555.davem@davemloft.net>
References: <1473254829-26438-1-git-send-email-oneukum@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oneukum@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50568 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752008AbcIHApw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 20:45:52 -0400
In-Reply-To: <1473254829-26438-1-git-send-email-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.com>
Date: Wed,  7 Sep 2016 15:27:09 +0200

> SOme statements in the driver only served to inform
> which functions were entered. Ftrace can do that just as good without
> needing memory. Remove the statements.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.com>

Applied to net-next, thanks Oliver.
