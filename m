From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: skge driver oops
Date: Fri, 12 May 2006 08:53:39 -0700
Message-ID: <20060512085339.72faaa44@localhost.localdomain>
References: <20060511150952.4c2cde2e@localhost.localdomain>
	<861.1147397784@d.0x1.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16830 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932142AbWELPxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 May 2006 11:53:42 -0400
To: "David Arnold" <david@mantara.com>
In-Reply-To: <861.1147397784@d.0x1.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 May 2006 11:36:24 +1000
"David Arnold" <david@mantara.com> wrote:

> i've been getting semi-regular lockups on my machine over 2.6.16
> series.  I recently attached a serial console in an attempt to capture
> an OOPS.
> 
> i got one yesterday.  it's copied manually from the console, but
> hopefully the values are all accurate.  there was more that had scrolled
> off screen above this too (sorry).
> 
> oops, lspci, uname -a, .config and dmesg below.
> 
> any suggestions for further debugging would be great,
> 
> thanks,

Could you retest with the v1.5 version that is 2.6.17-rc3?
