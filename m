From: Alex Chiang <achiang@canonical.com>
Subject: Re: [PATCH 2/2] dmi: save OEM defined slot information
Date: Fri, 28 May 2010 09:42:08 -0600
Message-ID: <20100528154208.GA15734@canonical.com>
References: <20100528120644.GB24114@littleblue.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"Domsch, Matt" <Matt_Domsch@dell.com>,
	"Hargrave, Jordan" <Jordan_Hargrave@dell.com>,
	"Rose, Charles" <Charles_Rose@dell.com>,
	"Nijhawan, Vijay" <Vijay_Nijhawan@dell.com>
To: "K, Narendra" <Narendra_K@dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100528120644.GB24114@littleblue.us.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* K, Narendra <Narendra_K@dell.com>:
> 
> This patch from Alex Chiang exports onboard device information
> as defined by SMBIOS type 209 for HP Proliants systems.

Hi,

Not sure if it really matters, but I'm no longer at HP and thus
my email address below is dead.

> From: Alex Chiang <achiang@hp.com>
> 
> Some legacy platforms provide onboard device information in an
> SMBIOS OEM- defined field, notably HP Proliants.

[snip] 
 
> Signed-off-by: Alex Chiang <achiang@hp.com>

I wrote this code when I was still at HP, so I suppose they
should get the git commit "credit" for it, unless there's already
a well-known convention of what to do when an email address
changes.

Thanks,
/ac
