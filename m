From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Thu, 15 Jun 2006 08:44:00 -0400
Message-ID: <20060615124355.GA32582@tuxdriver.com>
References: <20060607164801.GX24227@waste.org> <44871A19.7080805@intel.com> <x49d5dkvm8p.fsf@segfault.boston.redhat.com> <1149787174.2928.3.camel@strongmad> <x49ac8nwo83.fsf@redhat.com> <20060612001356.GA5112@localhost.localdomain> <1150130534.2879.9.camel@strongmad> <20060612180600.GB3790@hmsreliant.homelinux.net> <20060614204158.GA3967@hmsreliant.homelinux.net> <Pine.CYG.4.58.0606141635440.2888@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Matt Mackall <mpm@selenic.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-70-61-120-52.midsouth.biz.rr.com ([70.61.120.52]:25613
	"EHLO ra.tuxdriver.com") by vger.kernel.org with ESMTP
	id S1030322AbWFOMo5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 08:44:57 -0400
To: Mitch Williams <mitch.a.williams@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.CYG.4.58.0606141635440.2888@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 14, 2006 at 04:44:56PM -0700, Mitch Williams wrote:

> One of our engineers (on the I/O AT team) has been tasked with modifying
> the Linux kernel to properly support multiple hardware queues (both TX and
> RX).  We'll make sure that he looks at the netpoll interface as part of
> that process.

Might I ask who this is?  I might like to ping him/her on this topic.
There is potentially some overlap with wireless, at least on the
transmit side.

John
-- 
John W. Linville
linville@tuxdriver.com
