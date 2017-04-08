From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: ipv6: Remove unneccessary comments
Date: Sat, 8 Apr 2017 22:12:04 +0200
Message-ID: <20170408201204.GA2679@salvia>
References: <20170408154930.GA6924@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52972 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751505AbdDHUMM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 16:12:12 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C97752493E
        for <netdev@vger.kernel.org>; Sat,  8 Apr 2017 22:12:07 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5D712DA7F7
        for <netdev@vger.kernel.org>; Sat,  8 Apr 2017 22:12:12 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 82295DA86B
        for <netdev@vger.kernel.org>; Sat,  8 Apr 2017 22:12:09 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20170408154930.GA6924@arushi-HP-Pavilion-Notebook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 08, 2017 at 09:19:30PM +0530, Arushi Singhal wrote:
> This comments are obsolete and should go, as there are no set of rules per
> CPU anymore.

Applied, thanks.
