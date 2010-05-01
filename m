From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/3] ptp: Added a brand new class driver for ptp clocks.
Date: Sat, 1 May 2010 16:08:23 +0200
Message-ID: <20100501140823.GA2779@riccoc20.at.omicron.at>
References: <20100429091936.GA6703@riccoc20.at.omicron.at>
 <4BDB1A51.20505@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48523 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026Ab0EAOI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 10:08:26 -0400
Received: by fxm10 with SMTP id 10so981025fxm.19
        for <netdev@vger.kernel.org>; Sat, 01 May 2010 07:08:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4BDB1A51.20505@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 30, 2010 at 07:58:41PM +0200, Wolfgang Grandegger wrote:
> >  include/linux/Kbuild             |    1 +
> >  include/linux/ptp_clock.h        |   37 +++++
> 
> ptp_clock.h should probably be added to "include/linux/Kbuild".

But it already is, see the two lines above. Or did you mean something
else?

Thanks,
Richard
