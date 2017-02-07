From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: Re: [RFC v3 00/11] HFI Virtual Network Interface Controller (VNIC)
Date: Tue, 7 Feb 2017 13:43:03 -0800
Message-ID: <20170207214303.GA76652@knc-06.sc.intel.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20170207203649.GW6005@mtr-leonro.local>
 <1828884A29C6694DAF28B7E6B8A82373AB0E5B0B@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Leon Romanovsky <leon@kernel.org>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
        "Weiny, Ira" <ira.weiny@intel.com>
To: "Hefty, Sean" <sean.hefty@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30009 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932313AbdBGVnG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 16:43:06 -0500
Content-Disposition: inline
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373AB0E5B0B@ORSMSX109.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 01:00:05PM -0800, Hefty, Sean wrote:
>> I didn't read patches yet, and prefer to ask it in advance. Does this
>> new ULP work with all
>> drivers/infiniband/hw/* devices as it is expected from ULP?
>
>Like the way ipoib or srp work with all hw devices?  What is the real point of this question?

Leon,
It was already discussed in below threads.

https://www.spinics.net/lists/linux-rdma/msg44128.html
https://www.spinics.net/lists/linux-rdma/msg44131.html
https://www.spinics.net/lists/linux-rdma/msg44155.html

Niranjana
