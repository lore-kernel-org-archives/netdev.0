From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net v2 1/3] gtp: add genl family modules alias
Date: Thu, 26 Jan 2017 16:34:08 +0100
Message-ID: <20170126153408.GA1763@salvia>
References: <20170126151134.2892-1-aschultz@tpip.net>
 <20170126151134.2892-2-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49958 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753795AbdAZPeR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 10:34:17 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B40E012067
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 16:34:15 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A6B69DA2D3
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 16:34:15 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1E2C4A7DBC
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 16:34:09 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170126151134.2892-2-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 26, 2017 at 04:11:32PM +0100, Andreas Schultz wrote:
> Auto-load the module when userspace asks for the gtp netlink
> family.
> 
> Acked-by: Harald Welte <laforge@netfilter.org>
> Signed-off-by: Andreas Schultz <aschultz@tpip.net>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
