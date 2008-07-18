From: Stefan Roese <sr@denx.de>
Subject: Re: e1000e "Detected Tx Unit Hang"
Date: Fri, 18 Jul 2008 20:29:34 +0200
Message-ID: <200807182029.34890.sr@denx.de>
References: <4866211E.6040704@embedded-sol.com> <200807181744.46058.sr@denx.de> <4880BEDF.7070006@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Felix Radensky <felix@embedded-sol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:59955 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbYGRS3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 14:29:53 -0400
In-Reply-To: <4880BEDF.7070006@embedded-sol.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 18 July 2008, Felix Radensky wrote:
> > So it works for me. Only difference I can see is that I'm using 1000Mbps
> > and you only 100. Is this also 2.6.26 release from kernel.org? Which PCIe
> > slot are you using? I'm using PCIe1.
>
> I was using PCIe0. With PCIe1 everything works fine. Isn't it supposed
> to work with PCIe0
> as well ?

Yes, it should work in PCIe0 as well. I just tested there and see the same 
problems you reported. Hmmm, this will have to wait until after OLS I'm 
afraid.

Best regards,
Stefan
