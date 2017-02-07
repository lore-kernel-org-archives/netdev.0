From: Bart Van Assche <Bart.VanAssche@sandisk.com>
Subject: Re: [RFC v3 00/11] HFI Virtual Network Interface Controller (VNIC)
Date: Tue, 7 Feb 2017 21:58:50 +0000
Message-ID: <1486504716.2581.8.camel@sandisk.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
         <1486502926.2581.4.camel@sandisk.com>
         <1828884A29C6694DAF28B7E6B8A82373AB0E5B6C@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "dennis.dalessandro@intel.com" <dennis.dalessandro@intel.com>,
        "ira.weiny@intel.com" <ira.weiny@intel.com>
To: "dledford@redhat.com" <dledford@redhat.com>,
        "sean.hefty@intel.com" <sean.hefty@intel.com>,
        "niranjana.vishwanathapura@intel.com"
        <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa1.hgst.iphmx.com ([68.232.141.245]:44215 "EHLO
        esa1.hgst.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755409AbdBGV7e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 16:59:34 -0500
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373AB0E5B6C@ORSMSX109.amr.corp.intel.com>
Content-Language: en-US
Content-ID: <B95E13BFA1010D45A1220FA2FBB89C67@sandisk.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-07 at 21:44 +0000, Hefty, Sean wrote:
> This is Ethernet - not IP - encapsulation over a non-InfiniBand device/protocol.

That's more than clear from the cover letter. In my opinion the cover letter
should explain why it is considered useful to have such a driver upstream
and what the use cases are of encapsulating Ethernet frames inside RDMA
packets.

Bart.
