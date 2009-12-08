From: Andy Isaacson <adi@hexapodia.org>
Subject: Re: 2.6.32 regression, hard lock
Date: Mon, 7 Dec 2009 16:42:21 -0800
Message-ID: <20091208004221.GA15968@hexapodia.org>
References: <20091206141419.GA6195@linux-m68k.org> <20091207143057.53c6a362.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Zidlicky <rz@linux-m68k.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from straum.hexapodia.org ([64.81.70.185]:36059 "EHLO
	straum.hexapodia.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965184AbZLHAmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 19:42:15 -0500
Content-Disposition: inline
In-Reply-To: <20091207143057.53c6a362.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 07, 2009 at 02:30:57PM -0800, Andrew Morton wrote:
> btw, why does your kernel say "To Be Filled By O.E.M." in the traces? 
> The kernel.org kernel doesn't do that.  Is that kernel patched at all?

That's traditional for DMI_PRODUCT_NAME in dodgy vendor BIOSes.  I
routinely see it on Intel evaluation boards and less frequently on
Taiwanese Brand X boards.

-andy
