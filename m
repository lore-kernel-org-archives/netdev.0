From: jamal <hadi@cyberus.ca>
Subject: Re: ethernet QoS support?
Date: 09 Jul 2004 09:18:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089379137.1047.242.camel@jzny.localdomain>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com>
	 <40ED9A1C.4040707@pobox.com> <1089316845.1072.1.camel@jzny.localdomain>
	 <200407091002.26410.vkondra@mail.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>,
        Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200407091002.26410.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-07-09 at 03:02, Vladimir Kondratiev wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> I guess, Kumar is asking for support for several Tx queues with different 
> priorities. One need to start/stop these queues separately. This is dictated 
> by presense of different priorities on physical layer.

Exactly. I referenced him to you. Have you started any work yet?

cheers,
jamal
