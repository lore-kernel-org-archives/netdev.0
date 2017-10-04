From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] rndis_host: support Novatel Verizon USB730L
Date: Wed, 04 Oct 2017 12:44:20 +0200
Message-ID: <1507113860.9577.0.camel@suse.com>
References: <20170927213103.11987-1-aleksander@aleksander.es>
         <20171002.161750.1123671129875495210.davem@davemloft.net>
         <87k20cmitw.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: aleksander@aleksander.es, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34894 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751114AbdJDKog (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Oct 2017 06:44:36 -0400
In-Reply-To: <87k20cmitw.fsf@miraculix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, den 03.10.2017, 16:01 +0200 schrieb Bjørn Mork:
> Adding anything else, e.g. based on the table at
> http://www.usb.org/developers/defined_class/#BaseClassEFh , is a bit
> more risky.  We don't know if a driver will work with *any* such device
> until we've actually seen one.
> 
> This is just my opinion, and probably full of bogus assumptions as
> usual.  I was sort of hoping that some expert would speak up so I didn't
> have to :-)

Outside the vendors, there is nobody.

	Regards
		Oliver
