From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Please route new work through -mm tree?
Date: Wed, 29 Sep 2004 14:44:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929144419.6b455343.davem@davemloft.net>
References: <1096481023.8636.7.camel@localhost.localdomain>
	<415AFB63.7010107@us.ibm.com>
	<20040929132247.227fffcd.davem@davemloft.net>
	<415B220F.4040102@us.ibm.com>
	<20040929142401.664d8fd7.davem@davemloft.net>
	<415B2B2B.5050904@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <415B2B2B.5050904@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 17:37:47 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> David S. Miller wrote:
> > When I don't have any networking work present, that tree is
> > simply deleted.  So if you pull and get a URL error, that just
> > means no changes pending and Linus has everything. :-)
> 
> No need to delete it.  When Linus merges your stuff, net-2.6 tree 
> becomes equivalent to linux-2.6 tree.
> 
> When you next create and push local changes, a few days later, it is 
> guaranteed that there will be no conflicts between your local and 
> bkbits.net trees.

Ok, works for me.  I'll try to do this from now on.
