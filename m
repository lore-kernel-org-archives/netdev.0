From: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Subject: Re: Re: [PATCH] ebtables: Port ebt_[u]log.c to
	nf[netlink]_log
Date: Tue, 11 Oct 2005 20:49:16 +0000
Message-ID: <1129063757.5087.12.camel@localhost.localdomain>
References: <20051007234903.GR4450@rama.customers.eurospot.com>
	 <1129059110.5087.8.camel@localhost.localdomain>
	 <20051011.125506.46476570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
In-Reply-To: <20051011.125506.46476570.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ebtables-devel>
List-Id: netdev.vger.kernel.org

Op di, 11-10-2005 te 12:55 -0700, schreef David S. Miller:
> From: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
> Date: Tue, 11 Oct 2005 19:31:50 +0000
> 
> > I seem to be unable to get Davem's current git tree.
> > This fails miserably: 
> > cg-clone http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
> 
> I use an "alternates" file, so that Linus's tree's objects get used
> and only the truly local changes actually get stored in my tree.
> 
> Unfortunately that totally doesn't work with transports such
> as rsync.

OK, kernel now compiling without the patch. Harald, could you send it as
attachment?

The instructions at the top of http://www.kernel.org/git/ are somewhat
outdated.

cheers,
Bart




-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
