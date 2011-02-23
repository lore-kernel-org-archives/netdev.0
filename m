From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH V3] Export ACPI _DSM provided firmware instance number
	and string name to sysfs
Date: Wed, 23 Feb 2011 12:44:19 +0000
Message-ID: <20110223124419.GA5695@srcf.ucam.org>
References: <20110223125741.GA16473@fedora14-r610.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci@vger.kernel.org, linux-hotplug@vger.kernel.org,
	netdev@vger.kernel.org, Matt_Domsch@Dell.com,
	Charles_Rose@Dell.com, Jordan_Hargrave@Dell.com,
	Shyam_Iyer@Dell.com
To: Narendra_K@Dell.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110223125741.GA16473@fedora14-r610.blr.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think this version will still break the build. You need to depend on 
CONFIG_NLS.

-- 
Matthew Garrett | mjg59@srcf.ucam.org
