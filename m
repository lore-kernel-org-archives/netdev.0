From: Zhang Rui <rui.zhang@intel.com>
Subject: Re: [PATCH] ACPI: export acpi events via generic netlink
Date: Thu, 05 Jul 2007 16:54:30 +0800
Message-ID: <1183625670.8961.57.camel@localhost.localdomain>
References: <1182224403.5411.84.camel@localhost.localdomain>
	 <200707031545.16787.lenb@kernel.org>
	 <1183550487.3812.14.camel@johannes.berg>
	 <1183623847.8961.45.camel@localhost.localdomain>
	 <1183624541.3818.2.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Len Brown <lenb@kernel.org>,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1183624541.3818.2.camel@johannes.berg>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-05 at 10:35 +0200, Johannes Berg wrote:
> On Thu, 2007-07-05 at 16:24 +0800, Zhang Rui wrote:
> 
> > I missed the discussion about the multicast issues.
> > You don't need to reserve a family and group ID for ACPI. I'll rework
> > this on your patches.:)
> 
> I don't want to hold you, don't worry, I can handle it as well.
I got your comments on my original patch and it seems that we don't need
to change a lot with your patches applied. :)

> > But I don't know when these mutlicast patches can be merged while I hope
> > the function of exporting ACPI event via genetlink can be added ASAP.
> > 
> > I'm okay to hold off on this patch if you think the multicast patches
> > can be merged soon. Or else I tend to apply it first and send an
> > additional patch together with your patches later.
> 
> I personally think it's ready to go and haven't received any further
> comments, but maybe something will come up still. I'll wait a few days
> and then repost as an actual .23 submission.
That would be great. Can we add the ACPI genetlink patch to your patch
set and send them together? I'll refresh it based on your comments.

Thanks,
Rui
