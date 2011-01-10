From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V8 02/13] ntp: add ADJ_SETOFFSET mode bit
Date: Mon, 10 Jan 2011 08:22:26 +0100
Message-ID: <20110110072226.GB4864@riccoc20.at.omicron.at>
References: <cover.1293820862.git.richard.cochran@omicron.at>
 <fe2bec763bec155381d62721aa9da84aeca2785c.1293820862.git.richard.cochran@omicron.at>
 <AANLkTini2WdT-1v4k9V3JOZYDkA59P+SyscTe8-fK2Wk@mail.gmail.com>
 <20110108175028.GA22308@riccoc20.at.omicron.at>
 <AANLkTikigXGSACF6R6kfNHyKZ7GFWrUrCMxygvL3fUC6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43315 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab1AJHWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 02:22:30 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTikigXGSACF6R6kfNHyKZ7GFWrUrCMxygvL3fUC6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 10, 2011 at 06:07:26AM +0900, Kuwahara,T. wrote:
> 
> Another problem remains:  How do you deal with leap seconds?  I mean,

Since you have changed the topic, does that mean that you now agree
with adding a new mode bit? ;)

Richard
