From: Bart Van Assche <Bart.VanAssche@sandisk.com>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Thu, 4 May 2017 18:10:54 +0000
Message-ID: <1493921453.2692.6.camel@sandisk.com>
References: <20170504180216.7665-1-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "leonro@mellanox.com" <leonro@mellanox.com>,
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
To: "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "leon@kernel.org" <leon@kernel.org>,
        "dledford@redhat.com" <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.hgst.iphmx.com ([216.71.154.45]:28495 "EHLO
        esa6.hgst.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751738AbdEDSK7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 14:10:59 -0400
In-Reply-To: <20170504180216.7665-1-leon@kernel.org>
Content-Language: en-US
Content-ID: <FFEDBA5C678ECD4D8F50DEEAAB02F00D@namprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-05-04 at 21:02 +0300, Leon Romanovsky wrote:
> Following our discussion both in mailing list [1] and at the LPC 2016 [2]=
,
> we would like to propose this RDMA tool to be part of iproute2 package
> and finally improve this situation.

Hello Leon,

Although I really appreciate your work: can you clarify why you would like =
to
add *RDMA* functionality to an *IP routing* tool? I haven't found any motiv=
ation
for adding RDMA functionality to iproute2 in [1].

Thanks,

Bart.=
