From: Patrick McHardy <kaber@trash.net>
Subject: Re: more... iproute2/htb/whatever critical bug ?
Date: Tue, 27 Mar 2007 18:21:06 +0200
Message-ID: <46094472.1050807@trash.net>
References: <20070321175951.M73913@visp.net.lb>	<46026717.9060909@trash.net>	<20070322124533.M79867@visp.net.lb>	<46027FF2.6020001@trash.net> <20070322101224.3e6bb899@freekitty> <4602B96A.5000308@trash.net> <20070326182654.M24011@visp.net.lb> <460933EC.9060908@trash.net> <20070327155922.M1237@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62070 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932501AbXC0QVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 12:21:15 -0400
In-Reply-To: <20070327155922.M1237@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys wrote:
> Hi again
> 
> Looks like everything is fine, i will deploy at few NAS today night and will 
> see if there any issues.

Thanks for testing.

> Both oops what i gave, is it related to this bug?

Yes, they were both because of the same bug.

