From: Joe Perches <joe@perches.com>
Subject: Re: pull request: bluetooth-next 2012-03-01
Date: Sat, 03 Mar 2012 12:04:20 -0800
Message-ID: <1330805060.7070.18.camel@joe2Laptop>
References: <20120302163716.GA18758@joana>
	 <20120302.161501.1891197361615438878.davem@davemloft.net>
	 <20120303164655.GA5275@joana>
	 <20120303.144722.764199641223280924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: padovan@profusion.mobi, gustavo@padovan.org,
	johan.hedberg@gmail.com, linville@tuxdriver.com,
	marcel@holtmann.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:34371 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752992Ab2CCUEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2012 15:04:22 -0500
In-Reply-To: <20120303.144722.764199641223280924.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-03-03 at 14:47 -0500, David Miller wrote:
> From: Gustavo Padovan <padovan@profusion.mobi>
> Date: Sat, 3 Mar 2012 13:46:55 -0300
> 
> > Changing only the new code will put the Bluetooth subsystem in a
> > inconsistent coding style with different styles through the
> > subsystem.
> 
> Which btw would be perfectly fine, this is how we gradually fix
> coding style in other areas of the tree too.  So don't use crap
> like this as an excuse for not doing the right thing.
> 
> Requiring a big "fix all the coding style" patch before starting to do
> things properly in small increments first is completely bogus.

Style conformity is important to people for lots of
different reasons.

It's your choice but I personally think you should
give the bluetooth folk a chance to change their style
in a single largish whitespace commit immediately post
3.4 akin to the recent isdn one you just pulled.

If the bluetooth folk want help, I do have scripts
that would do a pretty decent job and make all
the git blame -w changes transparent.
