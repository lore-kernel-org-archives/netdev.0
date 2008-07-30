From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [RFC][PATCH 0/2] net: support for TX timestamps
Date: Wed, 30 Jul 2008 11:47:09 +0200
Message-ID: <200807301147.09643.netdev@axxeo.de>
References: <1217291753-5322-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:36433 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753034AbYG3JrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 05:47:14 -0400
In-Reply-To: <1217291753-5322-1-git-send-email-opurdila@ixiacom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Octavian,

Octavian Purdila schrieb:
> This patches adds TX timestamping support and is main use case is the
> Precision Time Protocol (IEEE 1588). Both software and hardware
> timestamping can be used.

Could you please include an example on how to use
this in userspace?

A proper place for this would be Documentation/net/

At the moment I cannot imagine how to use this and how
to correlate the sent packet with the timestamp.

That would also be a way to test your implementation and
test any changes done later to it. This will avoid future bitrot.

Many Thanks!


Best Regards

Ingo Oeser
