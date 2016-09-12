From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 16/16] MAINTAINERS: Update for PVRDMA driver
Date: Mon, 12 Sep 2016 11:52:22 -0600
Message-ID: <20160912175222.GG5843@obsidianresearch.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-17-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, jhansen@vmware.com, asarwade@vmware.com,
        georgezhang@vmware.com, bryantan@vmware.com
To: Adit Ranadive <aditr@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:33026 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932334AbcILRwX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 13:52:23 -0400
Content-Disposition: inline
In-Reply-To: <1473655766-31628-17-git-send-email-aditr@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 11, 2016 at 09:49:26PM -0700, Adit Ranadive wrote:
> Add maintainer info for the PVRDMA driver.

You can probably squash the last three patches.

.. and fix the __u32 stuff throughout the entire driver please.

Jason
