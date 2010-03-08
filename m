From: <Narendra_K@Dell.com>
Subject: RE: [PATCH] Export smbios strings associated with onboard devicesto sysfs
Date: Mon, 8 Mar 2010 23:27:10 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE612306@blrx3m08.blr.amer.dell.com>
References: <20100225202941.GA19404@mock.linuxdev.us.dell.com> <20100225204905.GC20147@mdomsch-pws380.aus.amer.dell.com> <EDA0A4495861324DA2618B4C45DCB3EE6122A2@blrx3m08.blr.amer.dell.com> <20100302173302.GA20936@mock.linuxdev.us.dell.com> <20100308173838.GC20953@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <Matt_Domsch@Dell.com>, <netdev@vger.kernel.org>,
	<linux-hotplug@vger.kernel.org>, <linux-pci@vger.kernel.org>,
	<Jordan_Hargrave@Dell.com>, <Sandeep_K_Shandilya@Dell.com>,
	<Charles_Rose@Dell.com>, <Shyam_Iyer@Dell.com>
To: <achiang@hp.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20100308173838.GC20953@ldl.fc.hp.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Alex Chiang [mailto:achiang@hp.com]
> Sent: Monday, March 08, 2010 11:09 PM
> To: K, Narendra
> Cc: Domsch, Matt; netdev@vger.kernel.org; linux-
> hotplug@vger.kernel.org; linux-pci@vger.kernel.org; Hargrave, Jordan;
> Shandilya, Sandeep K; Rose, Charles; Iyer, Shyam
> Subject: Re: [PATCH] Export smbios strings associated with onboard
> devicesto sysfs
> 
> * Narendra K <Narendra_K@dell.com>:
> >
> > Resending the patch with review comments incorporated.
> >
> > Signed-off-by: Jordan Hargrave <Jordan_Hargrave@dell.com>
> > Signed-off-by: Narendra K <Narendra_K@dell.com>
> 
> Here is a patch I wrote that would be nice if you could
> incorporate into your patch series.
> 
> It adds support for HP OEM SMBIOS record Type 209, so that you
> can populate the 'label' attribute on existing HP platforms.
> 
> It needs that hunk I suggested in my previous mail to apply
> cleanly.
> 

Sure, thanks.

With regards,
Narendra K
