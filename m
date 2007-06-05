From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and el bits)
Date: Tue, 5 Jun 2007 19:44:22 -0400
Message-ID: <20070605234422.GX31565@havoc.gtf.org>
References: <94c8ff9069a77568513a9a1d1e60012d@bga.com> <4660856E.80403@roinet.com> <fac4512e243d821a94e8ee7304240981@bga.com> <4665664D.30906@roinet.com> <b2809ae38545c6104771af3c3a8b2250@bga.com> <46659CF7.2070003@intel.com> <20070605173904.GP31565@havoc.gtf.org> <4665A0B6.6020902@intel.com> <4112397f218a0744ebf8656c81acf850@bga.com> <4665F2B8.3070805@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Milton Miller <miltonm@bga.com>,
	e1000-devel@lists.sourceforge.net, David Acker <dacker@roinet.com>,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:45378 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760141AbXFEXo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 19:44:29 -0400
Content-Disposition: inline
In-Reply-To: <4665F2B8.3070805@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 05, 2007 at 04:33:12PM -0700, Kok, Auke wrote:
> Jeff, please `git-revert d52df4a35af569071fda3f4eb08e47cc7023f094` to 
> revert the following patch for now:

Can you do me one more favor, and write a short paragraph describing why
it is getting reverted, to paste into the commit message?

You can do this yourself and have me git-pull the result, or I can do
the revert and paste the paragraph from email, your choice.

	Jeff



