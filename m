From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: r8169 and tg3
Date: Wed, 19 Nov 2003 12:24:59 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBBA76B.4070606@pobox.com>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com> <3FB9A277.70309@pobox.com> <20031118135848.A2451@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brad House <brad_mssw@gentoo.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20031118135848.A2451@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Jeff Garzik <jgarzik@pobox.com> :
> [...]
> 
>>So, what needs to happen is somebody needs to look at the sis190 changes 
>>that went in, and apply those same fixes to r8169.
> 
> 
> If no one objects, I can do for r8169 the same thing I did for sis190.
> Btw the DMA Rx/Tx rework is already in good shape (I rather like seeing
> Jeff improving (S)ATA than coming to copy over his RX and TX handling
> code :o) ).
> 
> Anyway, the bk-commit patches which were related to sis190 are available at:
> http://www.fr.zoreil.com/people/francois/misc/sis190-rework.mbx


hehe.  I certainly don't object...  You probably want to look over the 
r8169 v1.6 that Brad posted a link to, since it does have some improved 
8169 hardware support (modulo bugs, of course).

	Jeff
