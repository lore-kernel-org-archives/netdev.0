From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: e1000e "Detected Tx Unit Hang"
Date: Fri, 18 Jul 2008 19:03:43 +0300
Message-ID: <4880BEDF.7070006@embedded-sol.com>
References: <4866211E.6040704@embedded-sol.com> <200807181655.54760.sr@denx.de> <4880B88A.6060201@embedded-sol.com> <200807181744.46058.sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:38438 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbYGRQEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 12:04:00 -0400
In-Reply-To: <200807181744.46058.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Stefan

Stefan Roese wrote:
>
> So it works for me. Only difference I can see is that I'm using 1000Mbps and you only 
> 100. Is this also 2.6.26 release from kernel.org? Which PCIe slot are you using? I'm 
> using PCIe1.
>
>   
I was using PCIe0. With PCIe1 everything works fine. Isn't it supposed 
to work with PCIe0
as well ?

Felix.
