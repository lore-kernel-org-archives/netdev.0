From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/5] gtp: add genl family modules alias
Date: Tue, 24 Jan 2017 20:16:14 +0100
Message-ID: <20170124191614.GA9897@salvia>
References: <20170124172402.12096-1-aschultz@tpip.net>
 <20170124172402.12096-2-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36200 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750708AbdAXTQT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 14:16:19 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id F338F1EC2C4
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:16:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E433CDA8F5
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:16:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B62C5DA725
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:16:15 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170124172402.12096-2-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 06:23:58PM +0100, Andreas Schultz wrote:
> Auto-load the module when userspace asks for the gtp netlink
> family.

This qualifies as fix, since autoload is broken.

You may send a batch including this for David's net tree.
