From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: extended netdevice naming proposal
Date: Thu, 18 Nov 2010 12:52:25 -0600
Message-ID: <20101118185225.GB4952@auslistsprd01.us.dell.com>
References: <20101117220659.GA12177@auslistsprd01.us.dell.com> <4CE571B5.9070600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	narendra_k@dell.com, jcm@redhat.com, notting@redhat.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CE571B5.9070600@hp.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 18, 2010 at 10:34:29AM -0800, Rick Jones wrote:
> With the presence of the pci_slot driver to allow association of the PCI 
> address with a "slot name" is encoding such information into the interface 
> name really necessary?

I think so.  1) Dell systems seem not to be able to put information
into pci_slot.  That needs investigation.  2) if it's not in the name,
the user must do the correlation themselves manually.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
