From: Philippe De Muyter <phdm@macqel.be>
Subject: Re: udev and usb atm modems
Date: Mon, 22 Feb 2010 18:01:31 +0100
Message-ID: <20100222170131.GA3994@frolo.macqel>
References: <20100221145228.GB22165@frolo.macqel> <201002221654.o1MGsqkQ011451@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:58832 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751143Ab0BVRBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 12:01:36 -0500
Content-Disposition: inline
In-Reply-To: <201002221654.o1MGsqkQ011451@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chas,

On Mon, Feb 22, 2010 at 11:54:52AM -0500, Chas Williams (CONTRACTOR) wrote:
> In message <20100221145228.GB22165@frolo.macqel>,Philippe De Muyter writes:
> >This works perfectly, but /usr/local/bin/atm does busy waiting for the carrier
> >to appear.  Do you know if the atm subsystem provides a event to udev when
> >carrier becomes 1 ?
> 
> pretty sure it doesnt.  if you would like to contribute a patch...

Currently, I know nothing about sysfs or internals of udev.  But who knows ...

Philippe
