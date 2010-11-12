From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [e1000e] BUG triggered in blink path
Date: Thu, 11 Nov 2010 16:40:28 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1011111638570.14720@jbrandeb-desk1.amr.corp.intel.com>
References: <20101109083954.GB11829@mail.eitzenberger.org> <alpine.WNT.2.00.1011101030130.14720@jbrandeb-desk1.amr.corp.intel.com> <20101111101738.GA2972@mail.eitzenberger.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Holger Eitzenberger <holger@eitzenberger.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:42460 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755202Ab0KLAka (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Nov 2010 19:40:30 -0500
In-Reply-To: <20101111101738.GA2972@mail.eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 11 Nov 2010, Holger Eitzenberger wrote:
> I've attached the patch against net-next-2.6.  Please check if it's ok
> for you.  I checked e1000, igb and ixgbe as well, they don't have that
> problem.

Holger, 

I think the patch looks good and thanks.  Great catch too!  I see Jeff has 
put it into our testing process.

Reviewed-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
