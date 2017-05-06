From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Sat, 6 May 2017 12:40:47 +0200
Message-ID: <20170506104047.GC2017@nanopsycho>
References: <20170504180216.7665-1-leon@kernel.org>
 <1493921453.2692.6.camel@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "leon@kernel.org" <leon@kernel.org>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "leonro@mellanox.com" <leonro@mellanox.com>,
        "jiri@mellanox.com" <jiri@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "ram.amrani@cavium.com" <ram.amrani@cavium.com>,
        "sagi@grimberg.me" <sagi@grimberg.me>,
        "ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
        "dennis.dalessandro@intel.com" <dennis.dalessandro@intel.com>,
        "hch@lst.de" <hch@lst.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jgunthorpe@obsidianresearch.com" <jgunthorpe@obsidianresearch.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>
To: Bart Van Assche <Bart.VanAssche@sandisk.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36130 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752063AbdEFKku (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 06:40:50 -0400
Received: by mail-wr0-f193.google.com with SMTP id v42so2806859wrc.3
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 03:40:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1493921453.2692.6.camel@sandisk.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 04, 2017 at 08:10:54PM CEST, Bart.VanAssche@sandisk.com wrote:
>On Thu, 2017-05-04 at 21:02 +0300, Leon Romanovsky wrote:
>> Following our discussion both in mailing list [1] and at the LPC 2016 [2],
>> we would like to propose this RDMA tool to be part of iproute2 package
>> and finally improve this situation.
>
>Hello Leon,
>
>Although I really appreciate your work: can you clarify why you would like to
>add *RDMA* functionality to an *IP routing* tool? I haven't found any motivation
>for adding RDMA functionality to iproute2 in [1].

Bart, please realize that iproute2 is much more than "*IP routing* tool".
I understand you got confused by the name. Please see sources. Your comment
is totally pointless...
