From: Ian McDonald <imcdnzl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] ebtables: Port ebt_[u]log.c to nf[netlink]_log
Date: Thu, 13 Oct 2005 09:10:19 +1300
Message-ID: <cbec11ac0510121310v26a4c245h@mail.gmail.com>
References: <20051007234903.GR4450@rama.customers.eurospot.com>
	 <1129059110.5087.8.camel@localhost.localdomain>
	 <20051012062745.GB4237@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
In-Reply-To: <20051012062745.GB4237-d6usTx1WJblOCgDDqY8e12D2FQJk+8+b@public.gmane.org>
Content-Disposition: inline
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

On 12/10/05, Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org> wrote:
> On Tue, Oct 11, 2005 at 07:31:50PM +0000, Bart De Schuymer wrote:
> > I seem to be unable to get Davem's current git tree.
> > This fails miserably:
> > cg-clone http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.g=
it
>
> Try getting it via rsync, I never have successfully ran cg/git via http.
>
If you want to keep using a git tree have a look at a page I put together:
http://wlug.org.nz/KernelDevelopmentWithGit

Ian


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
