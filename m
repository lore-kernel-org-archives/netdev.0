From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch] workaround zd1201 interference problem
Date: Thu, 15 Jun 2006 16:10:31 -0400
Message-ID: <20060615201024.GD32582@tuxdriver.com>
References: <20060607140045.GB1936@elf.ucw.cz> <20060607160828.0045e7f5@griffin.suse.cz> <20060607141536.GD1936@elf.ucw.cz> <4486FD2F.8040205@gentoo.org> <20060608070525.GE3688@elf.ucw.cz> <4489ECD0.1030908@gentoo.org> <20060609223804.GB3252@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, Jiri Benc <jbenc@suse.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-70-61-120-52.midsouth.biz.rr.com ([70.61.120.52]:35588
	"EHLO ra.tuxdriver.com") by vger.kernel.org with ESMTP
	id S1031255AbWFOUKu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 16:10:50 -0400
To: Pavel Machek <pavel@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060609223804.GB3252@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 10, 2006 at 12:38:04AM +0200, Pavel Machek wrote:

> > Which operation is the one which stops the interference, the enable or 
> > the disable?
> 
> Disable alone was not enough to stop interference.

I'm going to drop this patch for now, in the hopes that with Daniel's
ZyDas contacts you can devise a more palatable solution.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
