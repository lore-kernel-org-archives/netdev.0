From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/3] sky2: revert to access PCI config via device space
Date: Sat, 01 Dec 2007 16:34:14 -0500
Message-ID: <4751D356.7060606@pobox.com>
References: <20071127105727.1bcfa56f@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32882 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751508AbXLAVeP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:34:15 -0500
In-Reply-To: <20071127105727.1bcfa56f@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Using the hardware window into PCI config space is more reliable
> and smaller/faster than using the pci_config routines. It avoids issues
> with MMCONFIG etc.
> 
> Reverts: 167f53d05fccb47b6eeadac7f6705b3f2f042d03
> 
> Please apply for 2.6.24
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied 1-3


