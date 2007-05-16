From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000: Fix msi enable leak on error, don't print error
 message,	cleanup
Date: Wed, 16 May 2007 18:00:47 -0400
Message-ID: <464B7F0F.10404@garzik.org>
References: <20070516083120.23311.3272.stgit@localhost.localdomain>	<464B2426.9060502@garzik.org>	<464B504B.5090007@hp.com> <464B55E1.8040501@zytor.com>	<464B5734.2070904@hp.com> <464B587A.70804@garzik.org> <464B6238.70102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33000 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760649AbXEPWA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 18:00:56 -0400
In-Reply-To: <464B6238.70102@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> Agreed.  But is the PCI (?) subsystem doing something in that regard or 
> is this a hole?

Depends on your platform, your BIOS, your kernel command line, ... :)

	Jeff


