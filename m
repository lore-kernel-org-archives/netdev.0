From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: Updated WE-18 (WPA) proposal
Date: Mon, 30 Aug 2004 10:42:15 -0700
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <20040830174215.GA32132@bougret.hpl.hp.com>
References: <20040830045441.GA7415@jm.kir.nu>
	<20040830165026.GD29492@bougret.hpl.hp.com>
	<413363CB.7060807@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Jouni Malinen <jkmaline@cc.hut.fi>,
	hostap@shmoo.com, Pedro Ramalhais <ramalhais@serrado.net>
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <413363CB.7060807@pobox.com>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 30, 2004 at 01:28:43PM -0400, Jeff Garzik wrote:
> Jean Tourrilhes wrote:
> >	Don't worry, I'll fix that. Anyway, WE-17 is pending in Jeff's
> >tree, and I don't think he will make major changes to it.
> 
> 
> hehe :)
> 
> Yep, it's merged in netdev-2.6 (and thus -mm as well), and queued for 
> upstream.

	Thanks ;-)

> FWIW any 'radical' wireless changes will go into wireless-2.6.  There is 
> still the stable upstream branch, to which WE patches can continue to be 
> applied...

	If you don't mind, I would like a bit more understanding about
how much is "radical" and how much is not. I would personally put that
around "breaking backward compatibility", but you may have other
ideas.
	Also, I'm not clear how the stuff in wireless-2.6 is supposed
to trickle into the other trees (netdev-2.6, -mm and Linus's), and how
to better link it with the CVS of the various drivers involved.

> 	Jeff

	Have fun...

	Jean
