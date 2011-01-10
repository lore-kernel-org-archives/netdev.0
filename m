From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] Export ACPI _DSM provided firmware instance number and
 string name to sysfs
Date: Mon, 10 Jan 2011 11:13:00 -0800
Message-ID: <20110110111300.58e6bbea@jbarnes-desktop>
References: <20101222170737.GA2428@fedora14-r610.oslab.blr.amer.dell.com>
	<20101223143203.GA12256@auslistsprd01.us.dell.com>
	<20101223194927.GA2717@fedora14-r610.oslab.blr.amer.dell.com>
	<20110107142750.21ea39f0@jbarnes-desktop>
	<E31FB011129F30488D5861F3839049151D10F8EF9D@BLRX7MCDC201.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <Matt_Domsch@Dell.com>, <linux-pci@vger.kernel.org>,
	<linux-hotplug@vger.kernel.org>, <netdev@vger.kernel.org>,
	<Jordan_Hargrave@Dell.com>, <Charles_Rose@Dell.com>,
	<Vijay_Nijhawan@Dell.com>
To: <Narendra_K@Dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <E31FB011129F30488D5861F3839049151D10F8EF9D@BLRX7MCDC201.AMER.DELL.COM>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 10 Jan 2011 10:48:26 -0800
<Narendra_K@Dell.com> wrote:
> > > > 'label' is fine for either case, with ACPI taking priority over
> > > > SMBIOS if both happen to be present.
> > > >
> > 
> > Applied, thanks.
> 
> Jesse,
> 
> Thank you.

Not sure if you saw it yet, but the patch caused a build breakage.  Can
you send me a replacement patch with a fix asap?

Thanks,
-- 
Jesse Barnes, Intel Open Source Technology Center
