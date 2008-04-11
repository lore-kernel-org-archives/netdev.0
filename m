From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Sat, 12 Apr 2008 02:25:36 +0400
Message-ID: <20080411222536.GA25893@2ka.mipt.ru>
References: <47FEADCB.7070104@rtr.ca> <20080410.172453.44434205.davem@davemloft.net> <47FEB062.3020003@rtr.ca> <20080410.173911.179180620.davem@davemloft.net> <47FEBDAA.7010305@rtr.ca> <Pine.LNX.4.64.0804110849520.28360@wrl-59.cs.helsinki.fi> <47FF6555.50004@rtr.ca> <20080411143537.GA27874@2ka.mipt.ru> <47FFE33C.1000707@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Lord <lkml@rtr.ca>,
	Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, Jeff Garzik <jeff@garzik.org>,
	rjw@sisk.pl, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44441 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756352AbYDKW0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 18:26:04 -0400
Content-Disposition: inline
In-Reply-To: <47FFE33C.1000707@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 12, 2008 at 12:16:28AM +0200, Tilman Schmidt (tilman@imap.cc) wrote:
> > Actually that will be the best decision from evolutional point of view. 
> 
> So I was right after all? Bug reports from people who (for whatever
> reason, including having to earn their living) cannot do a bisect are
> not welcome?

You got it wrong.

If bug is subtle and developers can not reproduce it, there are only two
ways out of the problem: to help developers or not to help.

In the latter case bug report is useless (except that to show that it
exists, since practically no one can fix it until some new details
added).

In the former case there is a discussion between developers and
reporters, so things have progress. In this particular case there were
no healthy discussion, that is why all this is about.

Bisection was just an example of the help, reporter can provide. In this
case there were no other suggestions remotely useful or they were
already tried. If you can not proceed with what was suggested, then do
not piss anyone off because you were told to do something to help.

If you go to the doctor because of aching throat and he asks you to
open a mouth, you will not blame him for asking you to do that.

-- 
	Evgeniy Polyakov
