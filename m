From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [PATCH] #2: add more reset debug messages
Date: Tue, 10 Aug 2004 20:24:12 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040811002412.GG26262@ruslug.rutgers.edu>
References: <200408101824.28368.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
In-Reply-To: <200408101824.28368.vda@port.imtp.ilyichevsk.odessa.ua>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


Same here, looks good we'll just need a patch against the kernel tree
too for netdev.

	Luis

On Tue, Aug 10, 2004 at 06:24:28PM +0300, Denis Vlasenko wrote:
> Hi Luis,
> 
> On top of previous one:
> 
> * Some not needed NULL assignments removed
> * Add some more printks to reset code path
> * mgt_commit_list(): tell which oid has failed
> 
> All previous concerns about this patch are addressed
> (some of removed NULL assignments were indeed needed).
> 
> Please apply.
> --
> vda



-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
