From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v3 0/2] GTP SGSN-side tunnels
Date: Fri, 24 Mar 2017 11:41:11 +0100
Message-ID: <20170324104111.GA1466@salvia>
References: <20170324093358.31374-1-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, laforge@gnumonks.org
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40532 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751714AbdCXKlv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 06:41:51 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6C1F7BA6E2
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 11:41:13 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5D0C2DA870
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 11:41:13 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 16B1FDA870
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 11:41:11 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170324093358.31374-1-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 24, 2017 at 10:33:56AM +0100, Jonas Bonn wrote:
> Changes since v2:
> 
> * Move #define of legacy netlink attribute into enum
> * Added note to commit message about load-testing use-case
> * Ack from Pablo

Thanks a lot Jonas!

David, please apply. Thanks!
