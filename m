From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Please route new work through -mm tree?
Date: Wed, 29 Sep 2004 18:30:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415B376B.9090704@pobox.com>
References: <1096481023.8636.7.camel@localhost.localdomain>	<415AFB63.7010107@us.ibm.com>	<20040929132247.227fffcd.davem@davemloft.net>	<415B220F.4040102@us.ibm.com>	<20040929142401.664d8fd7.davem@davemloft.net>	<415B2B2B.5050904@pobox.com> <20040929144419.6b455343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040929144419.6b455343.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 29 Sep 2004 17:37:47 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>David S. Miller wrote:
>>
>>>When I don't have any networking work present, that tree is
>>>simply deleted.  So if you pull and get a URL error, that just
>>>means no changes pending and Linus has everything. :-)
>>
>>No need to delete it.  When Linus merges your stuff, net-2.6 tree 
>>becomes equivalent to linux-2.6 tree.
>>
>>When you next create and push local changes, a few days later, it is 
>>guaranteed that there will be no conflicts between your local and 
>>bkbits.net trees.
> 
> 
> Ok, works for me.  I'll try to do this from now on.


Cool.  FWIW the only time you should need to blow away and reclone a 
tree is when you reorder changesets..

	Jeff
