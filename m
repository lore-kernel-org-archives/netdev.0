From: Terje Kvernes <terjekv@math.uio.no>
Subject: Re: linux-2.6.9 eepro100 warning
Date: Mon, 25 Oct 2004 21:54:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wxxr7nma801.fsf@nommo.uio.no>
References: <200410232313.AA00003@prism.kumin.ne.jp>
	<417C9A4E.3030909@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Seiichi Nakashima <nakasima@kumin.ne.jp>, linux-kernel@vger.kernel.org,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <417C9A4E.3030909@pobox.com> (Jeff Garzik's message of "Mon, 25
 Oct 2004 02:16:46 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> writes:

  [ ... ]

> Note that eepro100 driver will be deleted soon.

  we have several systems where e100 produces netdev watchdog errors,
  while eepro100 works without problems.  I can understand the desire
  to migrate, but what timeframe are we looking at?  roughly
  translated, when do I _have_ to start help debugging the e100
  driver?  ;-)

  I can do another attempt at rolling out the e100 driver, see what
  breaks, and try to report it around 2.6.1[01] or something like that
  if that helps?


-- 
Terje
