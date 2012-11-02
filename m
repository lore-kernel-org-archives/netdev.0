From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/4] Support the MX6 FEC as a PTP hardware clock
Date: Fri, 2 Nov 2012 09:43:24 +0100
Message-ID: <20121102084324.GA2486@netboy.at.omicron.at>
References: <1351657480-24745-1-git-send-email-Frank.Li@freescale.com>
 <20121101.123027.1332984905040252720.davem@davemloft.net>
 <CAHrpEqRuy=kewK-592RphVfJnNoma2CPZytoTqLc45HeT53hRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Frank.Li@freescale.com,
	shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37834 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754099Ab2KBInf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 04:43:35 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so1680663eek.19
        for <netdev@vger.kernel.org>; Fri, 02 Nov 2012 01:43:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAHrpEqRuy=kewK-592RphVfJnNoma2CPZytoTqLc45HeT53hRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 02, 2012 at 10:36:09AM +0800, Frank Li wrote:
> >
> > All applied to net-next.
> >
> > Please make sure your changes are in sync with Ben's PTP/PPS
> > Kconfig changes of today, and send me any changes if necessary.
> >
> 
> Thank you very much.
> I checked Ben's patch, which not affect FEC.

Maybe just remove the Kconfig line "select PPS".

Thanks,
Richard
