From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [REGRESSION next-20170426] Commit 09515ef5ddad ("of/acpi:
 Configure dma operations at probe time for platform/amba/pci bus devices")
 causes oops in mvneta
Date: Fri, 28 Apr 2017 17:00:05 +0200
Message-ID: <20170428150005.GY5077@suse.de>
References: <20170426181508.687b52af@gmail.com>
 <2fb57b9b-3944-d9cc-1fac-8dcccaa0c37a@codeaurora.org>
 <20170427164014.422a124c@gmail.com>
 <524b7fc8-1eca-a7d8-7bc7-6743be17c208@codeaurora.org>
 <20170428081919.21bb569d@gmail.com>
 <bcdcc1cc-181c-8396-dd3c-dd40d0c7efc1@codeaurora.org>
 <20170428142503.3b465425@gmail.com>
 <fa9a9c9b-68e5-251c-b640-6af5b1b3ce68@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralph Sennhauser <ralph.sennhauser@gmail.com>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Bjorn Helgaas <bhelgaas@google.com>,
        linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-pci@vger.kernel.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev@vger.kernel.org
To: Sricharan R <sricharan@codeaurora.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <fa9a9c9b-68e5-251c-b640-6af5b1b3ce68@codeaurora.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2017 at 06:48:33PM +0530, Sricharan R wrote:
> Also, probably this patch now going through the iommu tree looks more apt,
> as its for probe-deferral.
> Joerg, is that correct ?

Definitly. Please send the patch directly to me and I put it in the
tree.

Thanks,

	Joerg

