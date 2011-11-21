From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: Kernel v3.0.8 igb driver dies when pulling network cable
Date: Mon, 21 Nov 2011 19:07:42 +0100
Message-ID: <4ECA936E.8060301@profihost.ag>
References: <4ECA4362.2050307@profihost.ag> <4ECA884C.5010706@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stable Tree <stable@kernel.org>, stable@vger.kernel.org,
	Greg KH <gregkh@suse.de>, LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Jesse Brandeburg <jesse.brandeburg@intel.com> Bruce Allan"
	<bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4ECA884C.5010706@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> You are going to need to clarify some things since as far as I know we
> never released a v3.0.8 driver, and the kernel in the bug below is a
> version 2.6.40.8 which sounds more like a modified and possibly
> backported Linux kernel since as far as I know Linus never released a
> 2.6.40 kernel version.
Sorry that my description was so inaccurate. I'm talking about a vanilla 
v3.0.8 linux kernel. Just renamed to 2.6.40.8.

> In order to be able to assist you we will need some additional
> information.  What Linux distro are your running?  Do you have the
> latest updates from them?  Also have you tried running the latest
> out-of-tree driver we provide at e1000.sf.net in order to verify if the
> same issue occurs with that driver?
Linux Distri is Debian Lenny but we're running a self compiled vanilla 
3.0.X kernel. I haven't tried to use the up2date e1000.sf.net driver as 
3.0 is a long time supported kernel by greg - so all needed fixes should 
be backported or at least send to stable@ so that greg can have a look 
at them.

Thanks!

Stefan
