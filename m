From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: [PATCH] Export ACPI _DSM provided firmware instance number and string name to sysfs
Date: Wed, 5 Jan 2011 16:44:04 -0600
Message-ID: <20110105224404.GB4647@auslistsprd01.us.dell.com>
References: <20101222170737.GA2428@fedora14-r610.oslab.blr.amer.dell.com> <20101223143203.GA12256@auslistsprd01.us.dell.com> <20101223194927.GA2717@fedora14-r610.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci@vger.kernel.org, linux-hotplug@vger.kernel.org,
	netdev@vger.kernel.org, Jordan_Hargrave@Dell.com,
	Charles_Rose@Dell.com, Vijay_Nijhawan@Dell.com
To: Narendra_K@Dell.com, Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101223194927.GA2717@fedora14-r610.oslab.blr.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 23, 2010 at 11:24:36AM -0800, Narendra_K@Dell.com wrote:
> Please find the version 2 of the patch.
> 
> V1 -> V2:
> 
> The attribute 'index' is changed to 'acpi_index' as the semantics of
> SMBIOS provided device type instance and ACPI _DSM provided instance
> number are different.
> 
> From: Narendra K <narendra_k@dell.com>
> Subject: [PATCH V2] Export ACPI _DSM provided firmware instance number and string to sysfs
> 
> This patch exports ACPI _DSM (Device Specific Method) provided firmware
> instance number and string name of PCI devices as defined by
> 'PCI Firmware Specification Revision 3.1' section 4.6.7.( DSM for Naming
> a PCI or PCI Express Device Under Operating Systems) to sysfs.

Thanks Narendra and Jordan.

Jesse, how does this look for -next please?

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
