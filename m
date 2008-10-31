From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] phylib: mdio-ofgpio ---> mdio-gpio
Date: Fri, 31 Oct 2008 16:49:54 +0000
Message-ID: <20081031164954.GD26749@flint.arm.linux.org.uk>
References: <20081031155335.19905.14186.stgit@Programuotojas.82-135-208-232.ip.zebra.lt> <fa686aa40810310906j6845dd59kc9ccdce5c8213a0c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	Laurent Pinchart <laurentp@cse-semaphore.com>,
	Mike Frysinger <vapier.adi@gmail.com>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:49979 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbYJaQuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 12:50:14 -0400
Content-Disposition: inline
In-Reply-To: <fa686aa40810310906j6845dd59kc9ccdce5c8213a0c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2008 at 10:06:26AM -0600, Grant Likely wrote:
> On Fri, Oct 31, 2008 at 9:53 AM, Paulius Zaleckas
> <paulius.zaleckas@teltonika.lt> wrote:
> > Rename mdio-ofgpio driver to mdio-gpio and make it work with
> > non OpenFirmware gpio implementation.
> 
> Please respin this patch in 2 pieces; 1 patch to move the file and 1
> patch to make the changes.  It is difficult to review as a single
> patch.

Or ask for the diffs to be in git format (iow, using git diff -M).
Don't know if git-send-email can do that.
