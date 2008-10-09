From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Thu, 9 Oct 2008 11:04:02 +0000
Message-ID: <20081009110402.GA6588@ff.dom.local>
References: <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <48EC0190.7040804@trash.net> <48EC6286.1030202@cdi.cz> <20081008085325.GF4174@ff.dom.local> <48EC8FDD.5030507@cdi.cz> <20081009010957.GB6342@verge.net.au> <48EDA339.3040706@cdi.cz> <20081009095600.GB4159@ff.dom.local> <48EDE26B.6040101@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:61368 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756100AbYJILEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 07:04:09 -0400
Received: by ug-out-1314.google.com with SMTP id k3so900105ugf.37
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2008 04:04:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48EDE26B.6040101@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2008 at 12:52:27PM +0200, Martin Devera wrote:
...
> It starts to seem too complex to me (too many races related hypotheses).
> The original intent was to investigate possibly corrupted drr pointer,
> but just now I think the only way is to stuff enough debug code into
> htb and try myself...
> It will be probable faster - once I find time to do it.

Sure, but, on the other hand, isn't it too simple...

Jarek P.
