From: Terje Kvernes <terjekv@math.uio.no>
Subject: Re: linux-2.6.9 eepro100 warning
Date: Thu, 28 Oct 2004 17:45:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wxxekjiq21q.fsf@nommo.uio.no>
References: <200410232313.AA00003@prism.kumin.ne.jp>
	<417C9A4E.3030909@pobox.com> <wxxr7nma801.fsf@nommo.uio.no>
	<418077BC.10806@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Seiichi Nakashima <nakasima@kumin.ne.jp>, linux-kernel@vger.kernel.org,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <418077BC.10806@pobox.com> (Jeff Garzik's message of "Thu, 28
 Oct 2004 00:38:20 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> writes:

  [ ... ]

> If there are e100 problems, report them to the maintainers so we can
> get them resolved ASAP...

  I got a very nice mail from Jesse Brandeburg saying pretty much the
  same thing...  so, I've pushed kernels for around 75 boxen over to
  e100 today, from eepro100.  I'm not _quite_ sure when I'll have the
  chance to boot them all, but when they do, and if they have
  problems, I'll report back.
 
> INTEL PRO/100 ETHERNET SUPPORT
> P:      John Ronciak
> M:      john.ronciak@intel.com
> P:      Ganesh Venkatesan
> M:      ganesh.venkatesan@intel.com
> P:      Scott Feldman
> M:      scott.feldman@intel.com
> W:      http://sourceforge.net/projects/e1000/
> S:      Supported
> 
> (and of course netdev@oss.sgi.com as well)

  ack.

-- 
Terje - still waiting to test hotswap SATA.   =)
