From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][E1000E] some cleanups
Date: Sun, 30 Sep 2007 15:31:09 -0400
Message-ID: <1191180669.6165.50.camel@localhost>
References: <1191174077.6165.11.camel@localhost>
	 <46FFE809.8020504@intel.com> <1191178881.6165.40.camel@localhost>
	 <46FFF7AD.7090309@garzik.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.238]:37698 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbXI3TbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2007 15:31:13 -0400
Received: by wr-out-0506.google.com with SMTP id 36so1670454wra
        for <netdev@vger.kernel.org>; Sun, 30 Sep 2007 12:31:12 -0700 (PDT)
In-Reply-To: <46FFF7AD.7090309@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-30-09 at 15:23 -0400, Jeff Garzik wrote:

> Gotta wait a bit, otherwise we have confusion and a bit of breakage from 
> two drivers with the same PCI IDs.

ah, ok ;-> 
When i was testing i compiled out e1000. I am willing to totaly migrate
to e1000e, since major machine i have access to has PCIE. Auke, just let
me know what you need to do other than uncommenting the table entries
and i will leave you alone ;->

cheers,
jamal


