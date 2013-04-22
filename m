From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net] e1000e: fix numeric overflow in phc settime method.
Date: Mon, 22 Apr 2013 19:56:04 +0200
Message-ID: <20130422175604.GD2497@netboy>
References: <1455e8dd5f574fef93377b61cea8b494102091ef.1366638698.git.richardcochran@gmail.com>
 <1366653202.2037.2.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jeroen Van den Keybus <jeroen.vandenkeybus@triphase.com>,
	bruce.w.allan@intel.com, e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:53404 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414Ab3DVR4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 13:56:17 -0400
Received: by mail-we0-f176.google.com with SMTP id s10so1857007wey.35
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 10:56:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1366653202.2037.2.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 22, 2013 at 10:53:22AM -0700, Jeff Kirsher wrote:
> 
> Thanks Richard, I will add this to my queue.

If it doesn't make it into 3.9, please submit this one to stable, too.

Thanks,
Richard
