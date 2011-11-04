From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [net-next 03/10] seeq: Move the SEEQ drivers
Date: Fri, 4 Nov 2011 21:35:10 +0000
Message-ID: <20111104213509.GE12913@n2100.arm.linux.org.uk>
References: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com> <1313134384-7287-4-git-send-email-jeffrey.t.kirsher@intel.com> <20111104172446.GB12913@n2100.arm.linux.org.uk> <1320441002.5386.4.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Hamish Coleman <hamish@zot.apana.org.au>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:37369 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393Ab1KDVfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 17:35:30 -0400
Content-Disposition: inline
In-Reply-To: <1320441002.5386.4.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 04, 2011 at 02:10:02PM -0700, Jeff Kirsher wrote:
> I just submitted a patch to resolve this issue with the "sub" Kconfig's
> having a dependency which is not reflected in the "parent" Kconfig.
> 
> http://patchwork.ozlabs.org/patch/123250/

Thanks, that seems to fix the issues for me.  For that patch:

Tested-by: Russell King <rmk+kernel@arm.linux.org.uk>
