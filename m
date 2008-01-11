From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][ROSE][AX25] af_ax25: possible circular locking
Date: Fri, 11 Jan 2008 10:40:05 +0100
Message-ID: <20080111094005.GA2708@ff.dom.local>
References: <20071228214857.GA3290@ami.dom.local> <20071229.191443.10947724.davem@davemloft.net> <20071230141323.GA3377@ami.dom.local> <20080110.212242.42433023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f6bvp@free.fr, ralf@linux-mips.org, adobriyan@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:17905 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754671AbYAKJd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 04:33:56 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1058470fga.17
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 01:33:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080110.212242.42433023.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2008 at 09:22:42PM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 30 Dec 2007 15:13:23 +0100
> 
> > On Sat, Dec 29, 2007 at 07:14:43PM -0800, David Miller wrote:
...
> I've removed the warning and made the branch back to 'again'
> unconditional as I think this is the safest version of the
> change.
> 
> I'll push this upstream, thanks for fixing this Jarek.
> 

Thanks for checking this and making safer!

Regards,
Jarek P.
