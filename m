From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH v4] qe: miscellaneous code improvements and fixes to the
 QE library
Date: Wed, 03 Oct 2007 13:00:25 -0500
Message-ID: <4703D8B9.5080006@freescale.com>
References: <1191429299378-git-send-email-timur@freescale.com> <20071003094449.702c4a90@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	galak@kernel.crashing.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:53068 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755017AbXJCSAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 14:00:43 -0400
In-Reply-To: <20071003094449.702c4a90@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

> Separate the changes into individual patches to allow for better comment/review
> and bisection in case of regression.

That would be too difficult.  Some of the changes are single lines, and this 
patch has already been approved -- I just cross-posted to netdev because I 
made a few ucc_geth changes that can't be docoupled from the powerpc changes. 
  A series of 18 patches would just be convoluted.

-- 
Timur Tabi
Linux Kernel Developer @ Freescale
