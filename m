From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] alx: fix fallout from multi queue conversion
Date: Tue, 24 Jan 2017 15:28:52 -0500 (EST)
Message-ID: <20170124.152852.102221052664981755.davem@davemloft.net>
References: <cover.1485263833.git.tobias.regnery@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
To: tobias.regnery@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59384 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdAXU2y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:28:54 -0500
In-Reply-To: <cover.1485263833.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Regnery <tobias.regnery@gmail.com>
Date: Tue, 24 Jan 2017 14:34:21 +0100

> Here are 3 fixes for the multi queue conversion in v4.10.
> 
> The first patch fixes a wrong condition in an if statement.
> 
> Patches 2 and 3 fixes regressions in the corner case when requesting msi-x
> interrupts fails and we fall back to msi or legacy interrupts.

Series applied, thanks.
