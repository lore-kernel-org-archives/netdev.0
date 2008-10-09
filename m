From: Martin Devera <devik@cdi.cz>
Subject: Re: Possible regression in HTB
Date: Thu, 09 Oct 2008 08:53:49 +0200
Message-ID: <48EDAA7D.6040804@cdi.cz>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <20081008065551.GB4174@ff.dom.local> <20081008072203.GJ22396@verge.net.au> <20081008080340.GE4174@ff.dom.local> <20081009005437.GA6342@verge.net.au> <20081009062145.GA4159@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wifcom.cz ([89.185.251.8]:33939 "EHLO wifcom.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758751AbYJIGxx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 02:53:53 -0400
In-Reply-To: <20081009062145.GA4159@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It also looks like my idea that the first class could get not enough
> packets was wrong. It seems it's rather blocked by other classes when
> HTB thinks it can lend more.
> 
> Anyway, I'm also surprised HTB could be still so exact: congratulations
> Martin!

thanks for making my depressions smaller ;-) I'd like to make it work
even on edge..

devik
