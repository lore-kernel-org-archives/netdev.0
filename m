From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 0/7] Fixing the "Time Counter fixes and
 improvements"
Date: Fri, 2 Jan 2015 07:14:38 +0100
Message-ID: <20150102061437.GA4221@localhost.localdomain>
References: <CA+icZUXF6-_W6=YsajP4W84F5yvKCNtA3EYxKBgNS=aY4qAYPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:60829 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbbABGOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 01:14:44 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so27307836wiw.3
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2015 22:14:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CA+icZUXF6-_W6=YsajP4W84F5yvKCNtA3EYxKBgNS=aY4qAYPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 01, 2015 at 05:30:58PM +0100, Sedat Dilek wrote:
> With this conversion those 2 commits in net-next.git#master are obsolete now...
> 
> e1000e: Include clocksource.h to get CLOCKSOURCE_MASK.
> igb_ptp: Include clocksource.h to get CLOCKSOURCE_MASK.

Right. Okay, I'll rework this series to undo the obsolete includes.

Thanks,
Richard
