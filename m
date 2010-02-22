From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: udev and usb atm modems
Date: Mon, 22 Feb 2010 11:54:52 -0500
Message-ID: <201002221654.o1MGsqkQ011451@thirdoffive.cmf.nrl.navy.mil>
References: <20100221145228.GB22165@frolo.macqel>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: Philippe De Muyter <phdm@macqel.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:45723 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746Ab0BVQzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 11:55:07 -0500
In-reply-to: <20100221145228.GB22165@frolo.macqel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <20100221145228.GB22165@frolo.macqel>,Philippe De Muyter writes:
>This works perfectly, but /usr/local/bin/atm does busy waiting for the carrier
>to appear.  Do you know if the atm subsystem provides a event to udev when
>carrier becomes 1 ?

pretty sure it doesnt.  if you would like to contribute a patch...
