From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2012-03-01
Date: Sat, 03 Mar 2012 14:47:22 -0500 (EST)
Message-ID: <20120303.144722.764199641223280924.davem@davemloft.net>
References: <20120302163716.GA18758@joana>
	<20120302.161501.1891197361615438878.davem@davemloft.net>
	<20120303164655.GA5275@joana>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gustavo@padovan.org, johan.hedberg@gmail.com,
	linville@tuxdriver.com, marcel@holtmann.org, netdev@vger.kernel.org
To: padovan@profusion.mobi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38700 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990Ab2CCTsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 14:48:31 -0500
In-Reply-To: <20120303164655.GA5275@joana>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo Padovan <padovan@profusion.mobi>
Date: Sat, 3 Mar 2012 13:46:55 -0300

> Changing only the new code will put the Bluetooth subsystem in a
> inconsistent coding style with different styles through the
> subsystem.

Which btw would be perfectly fine, this is how we gradually fix
coding style in other areas of the tree too.  So don't use crap
like this as an excuse for not doing the right thing.

Requiring a big "fix all the coding style" patch before starting to do
things properly in small increments first is completely bogus.
