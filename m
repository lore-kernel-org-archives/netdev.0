From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 00/16] Add Paravirtual RDMA Driver
Date: Mon, 12 Sep 2016 12:02:51 -0600
Message-ID: <20160912180251.GH5843@obsidianresearch.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, jhansen@vmware.com, asarwade@vmware.com,
        georgezhang@vmware.com, bryantan@vmware.com
To: Adit Ranadive <aditr@vmware.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473655766-31628-1-git-send-email-aditr@vmware.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 11, 2016 at 09:49:10PM -0700, Adit Ranadive wrote:
> [2] Libpvrdma User-level library - 
> http://git.openfabrics.org/?p=~aditr/libpvrdma.git;a=summary

You will probably find that rdma-plumbing will be the best way to get
your userspace component into the distributors.

  http://www.spinics.net/lists/linux-rdma/msg39026.html
  http://www.spinics.net/lists/linux-rdma/msg39328.html
  http://www.spinics.net/lists/linux-rdma/msg40014.html
  http://www.spinics.net/lists/linux-rdma/msg39026.html

Jason
