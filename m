From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: RE: [RFC v3 00/11] HFI Virtual Network Interface Controller (VNIC)
Date: Tue, 7 Feb 2017 21:44:26 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373AB0E5B6C@ORSMSX109.amr.corp.intel.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1486502926.2581.4.camel@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
        "Weiny, Ira" <ira.weiny@intel.com>
To: Bart Van Assche <Bart.VanAssche@sandisk.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:41679 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932321AbdBGVon (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 16:44:43 -0500
In-Reply-To: <1486502926.2581.4.camel@sandisk.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This may have been stated before, but what is missing from this
> description
> is an explanation of why accepting an Ethernet over RDMA driver in the
> upstream kernel is considered useful. We already have an IPoIB driver,
> so
> why to add another driver to the kernel tree for communicating IP
> packets
> over an RDMA network?

This is Ethernet - not IP - encapsulation over a non-InfiniBand device/protocol.
