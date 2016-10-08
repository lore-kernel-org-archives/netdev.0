From: David Miller <davem@davemloft.net>
Subject: Re: Reversion of "xen-netback: create a debugfs node for hash
 information"
Date: Fri, 07 Oct 2016 23:48:56 -0400 (EDT)
Message-ID: <20161007.234856.1725862322997622606.davem@davemloft.net>
References: <cbedcf0845fb449892e415e2a1c69a40@AMSPEX02CL03.citrite.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wei.liu2@citrix.com
To: Paul.Durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59900 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756002AbcJHDs7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 23:48:59 -0400
In-Reply-To: <cbedcf0845fb449892e415e2a1c69a40@AMSPEX02CL03.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <Paul.Durrant@citrix.com>
Date: Fri, 7 Oct 2016 09:50:04 +0000

>   I notice that you have made the above reversion of commit c0c64c15
>   (debugfs node) due to a build failure, despite the failure being
>   caused by commit 0364a882 (switch to threaded irq) which was made
>   subsequently. I assume you want me to re-spin a new patch for the
>   debugfs node to fix the build problem?

Yes, that's probably what you need to do.

Thanks.
