From: <Narendra_K@Dell.com>
Subject: Re: [PATCH V3] Export ACPI _DSM provided firmware instance number
 and string name to sysfs
Date: Wed, 23 Feb 2011 18:30:23 +0530
Message-ID: <20110223132147.GB16707@fedora14-r610.blr.amer.dell.com>
References: <20110223125741.GA16473@fedora14-r610.blr.amer.dell.com>
 <20110223124419.GA5695@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-pci@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<netdev@vger.kernel.org>, <Matt_Domsch@Dell.com>,
	<Charles_Rose@Dell.com>, <Jordan_Hargrave@Dell.com>,
	<Shyam_Iyer@Dell.com>
To: <mjg59@srcf.ucam.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20110223124419.GA5695@srcf.ucam.org>
Content-Language: en-US
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 23, 2011 at 06:14:19PM +0530, Matthew Garrett wrote:
> I think this version will still break the build. You need to depend on 
> CONFIG_NLS.

Matthew,

Thanks. I posted a patch to linux-next to fix the build failure.

With regards,
Narendra K