From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: cvs commit'ed
Date: Sat, 14 Aug 2004 14:37:12 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040814183712.GH2050@ruslug.rutgers.edu>
References: <200408101824.28368.vda@port.imtp.ilyichevsk.odessa.ua>
	<20040811002844.GH26262@ruslug.rutgers.edu>
	<20040811005346.GK26262@ruslug.rutgers.edu>
	<200408141922.42792.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
	netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
In-Reply-To: <200408141922.42792.vda@port.imtp.ilyichevsk.odessa.ua>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 14, 2004 at 07:22:42PM +0300, Denis Vlasenko wrote:
> On Wednesday 11 August 2004 03:53, Luis R. Rodriguez wrote:
> > Denis,
> >
> > Actually you have CVS access to prism54, if no one complains about these
> > patches (and I think no one will as they are trivial), just go ahead and
> > commit these changes yourself. Please remember to update the ChangeLog too.
> >
> > After your changes go through I plan on starting to integrate the wpa work
> > I have (it can't wait any longer).
> 
> I did it. You may want to check whether cvs is still ok,
> it was the first time I ever used cvs ;]

Heh, I'm sure its fine. BTW I'd like us to move to subversion to use the
concepts of patchsets. I think this will help us keep our tree and the
kernel tree in sync.

> Shall I do something more to propagate changes into mainline
> or cvs commit done @prism54.org is enough?

cvs commit is enough. We still have to keep kernel tree in sync with our cvs rep.

Not sure if you've sent new patches out to Jeff/netdev
yet, have you? 2.6.8 is out so I'm assuming Jeff will now accept
non-bug-fix patches.

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
