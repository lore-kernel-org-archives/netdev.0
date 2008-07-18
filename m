From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [PATCH 0/6] netxen: add support for NX3031 chip
Date: Fri, 18 Jul 2008 16:23:47 -0700
Message-ID: <alpine.DEB.1.00.0807181620530.1245@unm84.unminc.com>
References: <> <1215890720-29744-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "jeff@garzik.org" <jeff@garzik.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.netxen.com ([66.126.254.36]:7706 "EHLO nxexch.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755387AbYGRXYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 19:24:08 -0400
In-Reply-To: <1215890720-29744-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

Please discard this series, I am going to send reworked patch series
shortly, that has more stuff than this one. That will have prefix
PATCHv2.

Thanks,
-Dhananjay

On Sat, 12 Jul 2008, Dhananjay Phadke wrote:

> This is first patch series to add support for NX3031 chip and
> NIC boards based on this hardware revision.
> 
> NX3031 chip has smaller PCI footprint (2MB) and different hardware              windowing. In order to retain compatibilty with older revisions,
> driver has wrapper functions for register access.
> 
> 
> 
> No virus found in this incoming message.
> Checked by AVG.
> Version: 7.5.526 / Virus Database: 270.4.9/1548 - Release Date: 7/12/2008 07:40
> 
> 
