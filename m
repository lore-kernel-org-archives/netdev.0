From: Robert Urban <urban@unix-beratung.de>
Subject: parsing ethtool output in programs/scripts
Date: Wed, 2 Sep 2015 02:22:18 +0200
Message-ID: <55E6413A.2060809@unix-beratung.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: bwh@kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dna.y42.org ([176.9.161.194]:32702 "EHLO dna.y42.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751571AbbIBA2r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 20:28:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I wish you would consider adding a switch to ethtool (and the corresponding
functionality) to produce output in machine-readable format.

This would be *extremely* useful.

Why not add the "--machine-readable" switch mentioned here:

   
http://www.hezmatt.org/~mpalmer/blog/2011/12/17/rethtool-how-i-learned-to-stop-worrying-and-love-the-ioctl.html

and another page which talks about the difficulty of parsing ethtool's output:

    http://pjrlost.blogspot.de/2011/11/linuxunix-and-new-output-pipe-stdobj.html

cheers,
Robert Urban
