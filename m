From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kexec: Export kexec_in_progress to modules
Date: Fri, 21 Oct 2016 10:13:43 -0400 (EDT)
Message-ID: <20161021.101343.1389577512803674816.davem@davemloft.net>
References: <1477012516-20470-1-git-send-email-f.fainelli@gmail.com>
        <20161020.215410.650162338407203719.davem@davemloft.net>
        <871szagtls.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        kexec@lists.infradead.org, linux-kernel@vger.kernel.org,
        sfr@canb.auug.org.au
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55344 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754883AbcJUONv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 10:13:51 -0400
In-Reply-To: <871szagtls.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 21 Oct 2016 00:26:55 -0500

> So as far as I can tell you are advocating for a change to support a
> driver doing something that is completely pointless.  So no let's not
> export this symbol.  Please fix the driver to do something less
> pointless instead.

FLorian explained his reasoning for doing what he is doing in this
specific driver and it made sense to me.
