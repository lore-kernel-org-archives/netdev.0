From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] solos-pci:Don't include pseudo-header in dump of
 frame
Date: Sun, 27 Mar 2011 23:30:55 -0700 (PDT)
Message-ID: <20110327.233055.98882402.davem@davemloft.net>
References: <4D901AF2.2040503@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: philipp_subx@redfish-solutions.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46171
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752112Ab1C1Gbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 02:31:33 -0400
In-Reply-To: <4D901AF2.2040503@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Date: Sun, 27 Mar 2011 22:21:54 -0700

>     Don't include pseudo-header as part of frame hex-dump on transmit.

Don't add this indentation in your commit messages, please.

> Signed-off-by: Philip Prindeville<philipp@redfish-solutions.com>

Also, where is the respun patch #1?

This is getty real tiring.

We have extensive documentation about how to submit patches
properly, you can start with Documentation/SubmittingPatches
in the kernel sources.

When I ask you to make changes to a patch series, resubmit
everything because I'm just going to mark whatever you submitted
already as "Changes Requested".

Thanks.
