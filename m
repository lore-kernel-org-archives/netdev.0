From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [PATCHv2 0/11] netxen: add support for NX3031 chip
Date: Mon, 21 Jul 2008 15:36:20 -0700
Message-ID: <alpine.DEB.1.00.0807211533230.16668@unm84.unminc.com>
References: <> <1216424649-4597-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "jeff@garzik.org" <jeff@garzik.org>
To: Jeff Garzik <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.netxen.com ([66.126.254.36]:7446 "EHLO nxexch.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755292AbYGUWjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 18:39:00 -0400
In-Reply-To: <1216424649-4597-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

grr .. patch 09 didn't pick up new file netxen_nic_ctx.c. This will 
break the build, since Makefile changes got picked up in that patch.

I gotta resend the patch series (with prefix RESENDv2).

-Dhananjay

On Fri, 18 Jul 2008, Dhananjay Phadke wrote:

> This is a reworked patchset that includes 5 of original patches and
> 6 new to complete the driver support for NetXen NX3031 chip and
> NIC boards based on it.
> 
> 
> 
