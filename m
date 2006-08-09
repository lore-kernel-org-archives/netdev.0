From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH 4/9] [TULIP] Clean tulip.h so it can be used by winbond-840.c
Date: Wed, 9 Aug 2006 09:00:55 -0600
Message-ID: <20060809150055.GA9316@colo.lackof.org>
References: <20060807204418.GE401@athena.road.mcmartin.ca> <11549840122892-git-send-email-kyle@parisc-linux.org> <11549840321096-git-send-email-kyle@parisc-linux.org> <1154984032324-git-send-email-kyle@parisc-linux.org> <115498403384-git-send-email-kyle@parisc-linux.org> <44D9739E.905@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kyle McMartin <kyle@parisc-linux.org>, netdev@vger.kernel.org,
	grundler@parisc-linux.org, val_henson@linux.intel.com,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:48356 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S1750936AbWHIPA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 11:00:59 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <44D9739E.905@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 01:33:18AM -0400, Jeff Garzik wrote:
> 2) nobody (but parisc folks?) knows what CBMA and CBIO mean.  Just use 
> "MMIO" and "PIO"

"CBIO" is what's in the public documentation. I just want to make it
easy for anyone who bothers to read the documentation to be sure
they are reading about the right register.

thanks,
grant

