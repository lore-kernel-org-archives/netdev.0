From: David Miller <davem@davemloft.net>
Subject: Re: [net-next V8 PATCH 0/5] New bpf cpumap type for XDP_REDIRECT
Date: Wed, 18 Oct 2017 12:12:38 +0100 (WEST)
Message-ID: <20171018.121238.1803733682298228804.davem@davemloft.net>
References: <150814913767.1806.3470498528707259987.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        mst@redhat.com, pavel.odintsov@gmail.com, jasowang@redhat.com,
        mchan@broadcom.com, john.fastabend@gmail.com,
        peter.waskiewicz.jr@intel.com, ast@fiberby.dk,
        borkmann@iogearbox.net, alexei.starovoitov@gmail.com,
        andy@greyhouse.net
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59664 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752467AbdJRLMt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 07:12:49 -0400
In-Reply-To: <150814913767.1806.3470498528707259987.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 16 Oct 2017 12:19:23 +0200

> Introducing a new way to redirect XDP frames.  Notice how no driver
> changes are necessary given the design of XDP_REDIRECT.

Series applied, thanks Jesper.
