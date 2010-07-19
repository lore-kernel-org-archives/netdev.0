From: <Narendra_K@Dell.com>
Subject: RE: [PATCH] Export SMBIOS provided firmware instance and label to sysfs
Date: Mon, 19 Jul 2010 22:24:39 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE612BD1@blrx3m08.blr.amer.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE612B93@blrx3m08.blr.amer.dell.com> <20100714121345.GA20411@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <Matt_Domsch@Dell.com>,
	<Charles_Rose@Dell.com>, <Jordan_Hargrave@Dell.com>,
	<Vijay_Nijhawan@Dell.com>
To: <Narendra_K@Dell.com>, <greg@kroah.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20100714121345.GA20411@auslistsprd01.us.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Narendra K
> Sent: Wednesday, July 14, 2010 5:44 PM
> To: greg@kroah.com
> Cc: netdev@vger.kernel.org; linux-hotplug@vger.kernel.org; linux-
> pci@vger.kernel.org; Domsch, Matt; Rose, Charles; Hargrave, Jordan;
> Nijhawan, Vijay
> Subject: Re: [PATCH] Export SMBIOS provided firmware instance and
label
> to sysfs
> 
> 
> V1 -> V2:
> 
> 1. The 'smbios_attr' buffer is not being used as mentioned above
> 
> 2. The function 'smbios_instance_string_exist' is split into two
> functions,
> the other being 'find_smbios_instance_string' which would print the
> result
> into the sysfs provided 'buf' of associated device. The function
> 'smbios_instance_string_exist' would let us know if the label exists
or
> not.
> 
> Please find the patch with above changes here -
> 
> From: Narendra K <narendra_k@dell.com>
> Subject: [PATCH] Export SMBIOS provided firmware instance and label to
> sysfs
> 

Greg,

Thanks for the review comments. 

This version of the patch has all the suggestions incorporated. Please
let us know if there are any concerns. If the approach is acceptable,
please consider this patch for inclusion.

With regards,
Narendra K
