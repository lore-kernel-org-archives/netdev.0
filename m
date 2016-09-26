From: Adit Ranadive <aditr@vmware.com>
Subject: Re: [PATCH v5 00/16] Add Paravirtual RDMA Driver
Date: Sun, 25 Sep 2016 22:25:12 -0700
Message-ID: <9f65ab5c-d8c2-e8e3-9334-5d1865a20dc9@vmware.com>
References: <cover.1474759181.git.aditr@vmware.com>
 <20160925070352.GU4088@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
        <pv-drivers@vmware.com>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <jhansen@vmware.com>,
        <asarwade@vmware.com>, <georgezhang@vmware.com>,
        <bryantan@vmware.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20160925070352.GU4088@leon.nu>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 25 2016 at 10:03:52AM +0300, Leon Romanovsky wrote:
> On Sat, Sep 24, 2016 at 04:21:24PM -0700, Adit Ranadive wrote:
> 
> <...>
> 
> >  include/uapi/rdma/pvrdma-abi.h                 |   99 ++
> >  include/uapi/rdma/pvrdma-uapi.h                |  255 +++++
> 
> As Jason said, you need a very good reason to split and create number of
> files per-driver in UAPI folder.

I can move the pvrdma-uapi.h back to the pvrdma driver folder.
