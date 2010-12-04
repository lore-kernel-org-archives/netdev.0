From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: kernel panic with time-stamping in phy devices (monitor mode)
Date: Sat, 4 Dec 2010 08:57:50 +0100
Message-ID: <20101204075750.GA3949@riccoc20.at.omicron.at>
References: <252997.92320.qm@web111013.mail.gq1.yahoo.com>
 <1291307884.2871.69.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Watts <akwatts@ymail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36071 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658Ab0LDH5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 02:57:55 -0500
Received: by fxm20 with SMTP id 20so2901709fxm.19
        for <netdev@vger.kernel.org>; Fri, 03 Dec 2010 23:57:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1291307884.2871.69.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Date: Sat, 4 Dec 2010 08:55:04 +0100
From: Richard Cochran <richardcochran@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Watts <akwatts@ymail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Subject: Re: kernel panic with time-stamping in phy devices (monitor mode)
Message-ID: <20101204075503.GA3490@riccoc20.at.omicron.at>
References: <252997.92320.qm@web111013.mail.gq1.yahoo.com>
 <1291307884.2871.69.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1291307884.2871.69.camel@edumazet-laptop>
User-Agent: Mutt/1.5.20 (2009-06-14)

Ugh, new kernel code with no users is already causing trouble!

On Thu, Dec 02, 2010 at 05:38:04PM +0100, Eric Dumazet wrote:
> Thanks for the report
> 
> Please try following patch.

And thank you, Eric, for the quick patch.

Can this fix go into 2.6.37, please?

Thanks,
Richard
