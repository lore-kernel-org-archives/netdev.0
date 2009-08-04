From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: [PATCH] pcnet32: remove superfluous NULL pointer check in pcnet32_probe1()
Date: Tue, 4 Aug 2009 12:32:56 +0200
Message-ID: <200908041233.02016.bzolnier@gmail.com>
References: <200907302319.18150.bzolnier@gmail.com> <200908022207.29942.bzolnier@gmail.com> <20090802.131256.210461366.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: pcnet32@verizon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, error27@gmail.com, corbet@lwn.net,
	eteo@redhat.com, julia@diku.dk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:65202 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932792AbZHDKe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 06:34:27 -0400
In-Reply-To: <20090802.131256.210461366.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 02 August 2009 22:12:56 David Miller wrote:
> From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> Date: Sun, 2 Aug 2009 22:07:29 +0200
> 
> > netdev@vger.kernel.org was on cc: for all patches...
> > 
> > http://marc.info/?l=linux-netdev&m=124898901714229&w=2
> > http://marc.info/?l=linux-netdev&m=124898901714236&w=2
> > 
> > maybe there is some problem with a patchwork setup..
> 
> My bad, I misread the CC: list, sorry.

There still may be some netdev patchwork problem..

These patches were applied with Don as an author:

commit 63097b3ad85788a64c75091bff351ecc850761b2
Author: Don Fry <pcnet32@verizon.net>
Date:   Fri Jul 31 08:45:29 2009 +0000

    pcnet32: VLB support fixes

...

commit df4e7f72f5156ef16a918da8a575ba90ec27ab77
Author: Don Fry <pcnet32@verizon.net>
Date:   Fri Jul 31 08:40:06 2009 +0000

    pcnet32: remove superfluous NULL pointer check in pcnet32_probe1()

...
