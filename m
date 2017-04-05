From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
        <u.kleine-koenig@pengutronix.de>
Subject: Re: pull-request: can 2017-04-04
Date: Wed, 5 Apr 2017 19:56:58 +0200
Message-ID: <20170405175658.7452mp6pplowvvgr@pengutronix.de>
References: <20170404155949.30965-1-mkl@pengutronix.de>
 <20170405.103734.436486519653060340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: mkl@pengutronix.de, netdev@vger.kernel.org, kernel@pengutronix.de,
        linux-can@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:37067 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753446AbdDER5C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 13:57:02 -0400
Content-Disposition: inline
In-Reply-To: <20170405.103734.436486519653060340.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 05, 2017 at 10:37:34AM -0700, David Miller wrote:
> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Tue,  4 Apr 2017 17:59:47 +0200
> 
> > this is a pull request of two patches for net/master.
> ...
> > The following changes since commit 0b9aefea860063bb39e36bd7fe6c7087fed0ba87:
> > 
> >   tcp: minimize false-positives on TCP/GRO check (2017-04-03 18:43:41 -0700)
> > 
> > are available in the git repository at:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git 
> 
> Pulling this doesn't give me anything:
> 
> [davem@kkuri net]$ git pull --no-ff git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git
> From git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can
>  * branch            HEAD       -> FETCH_HEAD
> Already up-to-date.

There is a tag linux-can-fixes-for-4.12-20170404 that contains the
commit id Marc mentioned. (Found using

	git ls-remote git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git | grep ca257b9e2

.)

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-König            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
