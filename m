From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 00/16] Add Paravirtual RDMA Driver
Date: Fri, 16 Sep 2016 10:32:01 -0600
Message-ID: <20160916163201.GC13911@obsidianresearch.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <20160912180251.GH5843@obsidianresearch.com>
 <BLUPR0501MB836ED564F2AE7AB9221AC25C5FF0@BLUPR0501MB836.namprd05.prod.outlook.com>
 <20160914173636.GA10309@obsidianresearch.com>
 <DM2PR0501MB844473AE0FCAD0FD748D43DC5F10@DM2PR0501MB844.namprd05.prod.outlook.com>
 <9C6B67F36DCAFC479B1CF6A967258A8C7DE14CE8@ORSMSX115.amr.corp.intel.com>
 <9C6B67F36DCAFC479B1CF6A967258A8C7DE14D3E@ORSMSX115.amr.corp.intel.com>
 <20160914225910.GB3567@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adit Ranadive <aditr@vmware.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        pv-drivers <pv-drivers@vmware.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "Jorgen S. Hansen" <jhansen@vmware.com>,
        Aditya Sarwade <asarwade@vmware.com>,
        George Zhang <georgezhang@vmware.com>,
        Bryan Tan <bryantan@vmware.com>
To: "Woodruff, Robert J" <robert.j.woodruff@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:39614 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935781AbcIPQcH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 12:32:07 -0400
Content-Disposition: inline
In-Reply-To: <20160914225910.GB3567@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 04:59:10PM -0600, Jason Gunthorpe wrote:

> > package follows that licensing model for accepting any new code into
> > that combined repo ?
> 
> As with the kernel we'd discourage 're-licensing' existing files.
> 
> However, since this is not a OFA project, I, personally, would not
> turn away a GPLv2 compatible contribution, but I am proposing that the
> 'default' license for the project be OFA compatible.

I should be clearer here. I am *strongly* opposed to anything that
changes the license of the existing 4 core libraries away from the
GPLv2 or OpenIB.org situation we have today. (that includes to other
varients of the BSD license)

I just checked and we appear to be completely OK on this point today.

Jason
