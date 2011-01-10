From: <Narendra_K@Dell.com>
Subject: RE: [PATCH] Export ACPI _DSM provided firmware instance number and
 string name to sysfs
Date: Mon, 10 Jan 2011 11:35:41 -0800
Message-ID: <E31FB011129F30488D5861F3839049151D10F8EFB7@BLRX7MCDC201.AMER.DELL.COM>
References: <20101222170737.GA2428@fedora14-r610.oslab.blr.amer.dell.com>
	<20101223143203.GA12256@auslistsprd01.us.dell.com>
	<20101223194927.GA2717@fedora14-r610.oslab.blr.amer.dell.com>
	<20110107142750.21ea39f0@jbarnes-desktop>
	<E31FB011129F30488D5861F3839049151D10F8EF9D@BLRX7MCDC201.AMER.DELL.COM>
 <20110110111300.58e6bbea@jbarnes-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <Matt_Domsch@Dell.com>, <linux-pci@vger.kernel.org>,
	<linux-hotplug@vger.kernel.org>, <netdev@vger.kernel.org>,
	<Jordan_Hargrave@Dell.com>, <Charles_Rose@Dell.com>,
	<Vijay_Nijhawan@Dell.com>
To: <jbarnes@virtuousgeek.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20110110111300.58e6bbea@jbarnes-desktop>
Content-Language: en-US
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Jesse Barnes [mailto:jbarnes@virtuousgeek.org]
> Sent: Tuesday, January 11, 2011 12:43 AM
> To: K, Narendra
> Cc: Domsch, Matt; linux-pci@vger.kernel.org; linux-
> hotplug@vger.kernel.org; netdev@vger.kernel.org; Hargrave, Jordan;
> Rose, Charles; Nijhawan, Vijay
> Subject: Re: [PATCH] Export ACPI _DSM provided firmware instance number
> and string name to sysfs
> 
> On Mon, 10 Jan 2011 10:48:26 -0800
> <Narendra_K@Dell.com> wrote:
> > > > > 'label' is fine for either case, with ACPI taking priority over
> > > > > SMBIOS if both happen to be present.
> > > > >
> > >
> > > Applied, thanks.
> >
> > Jesse,
> >
> > Thank you.
> 
> Not sure if you saw it yet, but the patch caused a build breakage.  Can
> you send me a replacement patch with a fix asap?
> 
> Thanks,

Just saw it now. Sorry for the inconvenience. I took the patch against linux-2.6 where I did not see the failure. I am pulling the linux-next now, will get this resolved first thing tomorrow.

With regards,
Narendra K

