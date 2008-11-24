From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: pull request: wireless-2.6 2008-11-18
Date: Mon, 24 Nov 2008 14:33:14 +0800
Message-ID: <1227508394.2548.307.camel@debian.sh.intel.com>
References: <20081119000719.GA19756@tuxdriver.com>
	 <1ba2fa240811182246m17a6baf0ybde19af030a65819@mail.gmail.com>
	 <1ba2fa240811190134u7974a840i532e8ed0e18f8c72@mail.gmail.com>
	 <20081119143919.GA3485@tuxdriver.com>
	 <1227497655.2548.257.camel@debian.sh.intel.com>
	 <7E134DC0-A86D-460A-B5DC-22E6D9BEED92@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Tomas Winkler <tomasw@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>
To: Marcel Holtmann <holtmann@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61410 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750954AbYKXGcz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 01:32:55 -0500
In-Reply-To: <7E134DC0-A86D-460A-B5DC-22E6D9BEED92@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-11-24 at 11:50 +0800, Marcel Holtmann wrote:
> http://www.intellinuxwireless.org/bugzilla/show_bug.cgi?id=1703
> 
> and just relying on Bugzilla is not gonna be good enough. The Linux  
> kernel development has always been done via mailing lists. And while  
> there is a kernel and other Bugzillas, the main authority is still the
> mailing list. So if you wanna get massive feedback or have testing  
> patches for debugging, then these need to be posted to linux-wireless
> and not "hidden" into a Bugzilla.

This is generally true for bugs easy to debug with. But in this example,
the first reporter opened this bug 4 months ago. People usually don't
follow thread for such a long time. There are also some reporters never
show up in this ML.

> I do have a perfect environment in Vancouver that allows me to trigger
> this behavior within a few minutes. So if you really wanna debug this,
> then just send debug patches to the mailing list and I am happy to run
> such kernels.

Can you still reproduce this bug with Johannes' patch?

Thanks,
-yi

