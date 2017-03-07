From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] rds: tcp: fix various rds-tcp issues during
 netns create/delete sequences
Date: Tue, 07 Mar 2017 14:10:20 -0800 (PST)
Message-ID: <20170307.141020.673611665952215585.davem@davemloft.net>
References: <cover.1488645926.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, santosh.shilimkar@oracle.com,
        netdev@vger.kernel.org, syzkaller@googlegroups.com,
        rds-devel@oss.oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43058 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933410AbdCHHFW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 02:05:22 -0500
In-Reply-To: <cover.1488645926.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Sat,  4 Mar 2017 08:57:32 -0800

> Dmitry Vyukov reported some syszkaller panics during netns deletion.
 ...

Series applied, thanks!
