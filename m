From: Marc Zyngier <mzyngier@freesurf.fr>
Subject: Re: [PATCH][2.6] de4x5 cleanup
Date: Sat, 30 Aug 2003 21:04:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wrpn0dr55n1.fsf@hina.wild-wind.fr.eu.org>
References: <wrpad9r79g6.fsf@hina.wild-wind.fr.eu.org>
	<3F50E3FD.1000703@pobox.com>
Reply-To: mzyngier@freesurf.fr
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, linux-net@vger.kernel.org,
   Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F50E3FD.1000703@pobox.com> (Jeff Garzik's message of "Sat, 30
 Aug 2003 13:50:53 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Jeff" == Jeff Garzik <jgarzik@pobox.com> writes:

Jeff> It looks pretty good.  My big objection isn't the Space.c stuff
Jeff> but de4x5 itself.  I had hoped it would be gone by now :) Oh
Jeff> well, not your fault.

Well... I too, had hoped the tulip (and its dc21040 derivative)
driver would be the only one. While it works nicely on modern stuff
(2114[023]), it has some problems on a few of my test boxes (mostly
Alphas with onboard 21040).

And most of all, tulip doesn't support EISA :-).

Thanks,

        M.
-- 
Places change, faces change. Life is so very strange.
