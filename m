From: "Woodruff, Robert J" <robert.j.woodruff@intel.com>
Subject: RE: [PATCH v4 00/16] Add Paravirtual RDMA Driver
Date: Wed, 14 Sep 2016 22:20:22 +0000
Message-ID: <9C6B67F36DCAFC479B1CF6A967258A8C7DE14D3E@ORSMSX115.amr.corp.intel.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <20160912180251.GH5843@obsidianresearch.com>
 <BLUPR0501MB836ED564F2AE7AB9221AC25C5FF0@BLUPR0501MB836.namprd05.prod.outlook.com>
 <20160914173636.GA10309@obsidianresearch.com>
 <DM2PR0501MB844473AE0FCAD0FD748D43DC5F10@DM2PR0501MB844.namprd05.prod.outlook.com>
 <9C6B67F36DCAFC479B1CF6A967258A8C7DE14CE8@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        pv-drivers <pv-drivers@vmware.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "Jorgen S. Hansen" <jhansen@vmware.com>,
        Aditya Sarwade <asarwade@vmware.com>,
        George Zhang <georgezhang@vmware.com>,
        Bryan Tan <bryantan@vmware.com>
To: "Woodruff, Robert J" <robert.j.woodruff@intel.com>,
        Adit Ranadive <aditr@vmware.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <9C6B67F36DCAFC479B1CF6A967258A8C7DE14CE8@ORSMSX115.amr.corp.intel.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Woody Wrote,
>We are still discussing this within the OFA EWG for the OFED releases. I suspect that if all of the maintainers of the user-space packages agree to merge into >and support this new merged repo-model, then OFED would eventually base their OFED user-space packages on that repo, rather than the individual repo's >that are used today. The question is, when. Work has now just started on OFED-4.8, that is based on the kernel.org 4.8 kernel. If this new scheme works with >kernel.org 4.8, then it is possible that it could go into that OFED-4.8 Release, but again, we are still looking at the new scheme and evaluating how it affects >the community OFED.

One other question.  Jason, the OFA (and its members) want to maintain the dual-license (BSD/GPL) for the code, as is the case for all the code that was in the OFA git trees on the OFA server that you pulled from. Will you guys be ensuring that this new user-space package 
follows that licensing model for accepting any new code into that combined repo ?
