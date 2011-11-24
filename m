From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH] virtio_net: Give indication on device probe failure.
Date: Thu, 24 Nov 2011 10:35:22 +0200
Message-ID: <1322123722.4248.4.camel@lappy>
References: <20111124082421.26821.71126.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, mst@redhat.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:42580 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334Ab1KXIf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 03:35:27 -0500
Received: by ggnr5 with SMTP id r5so2315945ggn.19
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 00:35:26 -0800 (PST)
In-Reply-To: <20111124082421.26821.71126.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-24 at 13:54 +0530, Krishna Kumar wrote:
> Provide an indication when the virtio_net device fails to
> initialize.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---

[snip]

You already get a warning from the thingie that probes PCI:

[    1.166311] virtio_net: probe of virtio1 failed with error -12

-- 

Sasha.
