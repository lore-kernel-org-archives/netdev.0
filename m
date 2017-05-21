From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 00/12] Netfilter/IPVS fixes for net
Date: Mon, 22 May 2017 00:25:38 +0200
Message-ID: <20170521222538.GA2370@salvia>
References: <1495182833-2272-1-git-send-email-pablo@netfilter.org>
 <20170521.130033.1427773613973278051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58782 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757259AbdEUWZm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 May 2017 18:25:42 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B107713BB82
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 00:25:34 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A270EFF2F1
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 00:25:34 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A372DFF2D7
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 00:25:32 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20170521.130033.1427773613973278051.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 21, 2017 at 01:00:33PM -0400, David Miller wrote:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Fri, 19 May 2017 10:33:41 +0200
> 
> > The following patchset contains Netfilter/IPVS fixes for your net tree,
> > they are:
>  ...
> > You can pull these changes from:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git
> 
> Pulled, thanks Pablo.

Thanks David!

Could you merge net into net-next as well? I have several patches for
net-next that need to apply on these fixes. No rush BTW.
