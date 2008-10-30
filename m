From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: Netconsole and logging everything from /dev/console
Date: Thu, 30 Oct 2008 16:16:29 +0100
Message-ID: <20081030151629.GP2527@deprecation.cyrius.com>
References: <87bpx2gn9j.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ferenc Wagner <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:4157 "EHLO sorrow.cyrius.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755281AbYJ3PQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2008 11:16:45 -0400
Content-Disposition: inline
In-Reply-To: <87bpx2gn9j.fsf@tac.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ferenc Wagner <wferi@niif.hu> [2008-10-30 15:39]:
> >> It is, definitely, you just need to wire up a tty struct's write
> >> method to netconsole's and add it to the console registration. But I
> >> haven't had any time to work on this in a while.
> >
> > Where would I look for examples I could follow?
> Such feature would indeed be useful.  Did you get anywhere with it?

Nope.
-- 
Martin Michlmayr
http://www.cyrius.com/
