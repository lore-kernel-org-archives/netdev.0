From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 080/493] fddi: remove use of __devexit_p
Date: Mon, 19 Nov 2012 22:22:52 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1211192222160.12904@nerf07.vanv.qr>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu> <1353349642-3677-80-git-send-email-wfp5p@virginia.edu> <alpine.LFD.2.02.1211191842180.25230@eddie.linux-mips.org> <alpine.LFD.2.02.1211191912040.25230@eddie.linux-mips.org>
 <20121119192949.GA16976@kroah.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Bill Pemberton <wfp5p@virginia.edu>, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:46348 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751883Ab2KSVWx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2012 16:22:53 -0500
In-Reply-To: <20121119192949.GA16976@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 2012-11-19 20:29, Greg KH wrote:
>
>CONFIG_HOTPLUG is always enabled now, so that's not an option anymore.
>And again, a user can "hot unbind" a driver from a device from
>userspace, no matter if the bus physically supports it or not.

Which mailing list was this originally posted on? (I only have 
subscribed to netdev, and google has not indexed 000/493--001/493 yet.)
