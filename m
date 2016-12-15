From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: RE: [RFC v2 03/10] IB/hfi-vnic: Virtual Network Interface
 Controller (VNIC) netdev
Date: Thu, 15 Dec 2016 17:21:05 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373AB0C9556@ORSMSX109.amr.corp.intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1481788782-89964-4-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215170109.GC3264@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
        "Weiny, Ira" <ira.weiny@intel.com>,
        "Warrier, Sadanand" <sadanand.warrier@intel.com>,
        "Dutt, Sudeep" <sudeep.dutt@intel.com>,
        "Jajodia, Tanya K" <tanya.k.jajodia@intel.com>,
        "Kacprowski, Andrzej" <Andrzej.Kacprowski@intel.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57786 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755134AbcLORVj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 12:21:39 -0500
In-Reply-To: <20161215170109.GC3264@obsidianresearch.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This goes on the network too? Also looks like it has endian problems.

I don't think OPA supports BE systems, and I think it uses LE on the wire for at least some portions of its protocol.
