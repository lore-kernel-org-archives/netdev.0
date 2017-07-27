From: "Raj, Ashok" <ashok.raj@intel.com>
Subject: Re: [PATCH v7 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Thu, 27 Jul 2017 11:42:51 -0700
Message-ID: <20170727184251.GA205508@otc-nc-03>
References: <67be791f-e0cf-8284-9229-17174dc741ef@codeaurora.org>
 <5f9b8bfb-41a8-a17c-6fea-581aec1d5573@huawei.com>
 <20170724090516.2e0f0d2a@w520.home>
 <MWHPR12MB1600065968964410EDFBDA3BC8B90@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0UeAad6WArvrE71MFJywDs1wOnCF-iJRnbNLrL+knqhXeA@mail.gmail.com>
 <CAKgT0Uf5hdXUXja_jUB6_kBg6pyX8zXuOMOGzCVNgeBFMUsWqQ@mail.gmail.com>
 <CAKgT0Udn2vh6NaqZyiF69nXVnz2sT=e0ZgiDjWznhGZz-Gk+qQ@mail.gmail.com>
 <MWHPR12MB16007782C422082A92F4765DC8B90@MWHPR12MB1600.namprd12.prod.outlook.com>
 <2feff1a5-25b7-eb6c-7628-7c2257c56e95@huawei.com>
 <MWHPR12MB1600556FFDCE3EC810D97591C8BE0@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ding Tianhong <dingtianhong@huawei.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Bjorn Helgaas <helgaas@kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "David.Laight@aculab.com" <David.Laight@aculab.com>,
        Alex Williamson <alex.williamson@redhat.com>,
        "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
        "Suravee.Suthikulpanit@amd.com" <Suravee.Suthikulpanit@amd.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        Sinan Kaya <okaya@codeaurora.org>,
        "robin.murphy@arm.com" <robin.murphy@arm.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.n
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <MWHPR12MB1600556FFDCE3EC810D97591C8BE0@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Casey

> | Still no Intel and AMD guys has ack this, this is what I am worried about,
> | should I ping some man again ?


I can ack the patch set for Intel specific changes. Now that the doc is made
public :-).

Can you/Ding resend the patch series, i do have the most recent v7, some
of the commit message wasn't easy to ready. Seems like this patch has
gotten bigger than originally intended, but seems to be for the overall
good :-).

Sorry for staying silent up until now.

Cheers,
Ashok
