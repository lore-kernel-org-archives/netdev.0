From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [0/8] orinoco driver updates
Date: Tue, 01 Feb 2005 20:48:31 -0500
Message-ID: <4200316F.7030401@pobox.com>
References: <20050112052352.GA30426@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: orinoco-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
To: David Gibson <david@gibson.dropbear.id.au>
In-Reply-To: <20050112052352.GA30426@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Gibson wrote:
> Following are a bunch of patches which make a few more steps towards
> the long overdue merge of the CVS orinoco driver into mainline.  These
> do make behavioural changes to the driver, but they should all be
> trivial and largely cosmetic.

OK, the changes look good, but I was waiting for the previous stuff you 
submitted to land in upstream.

Could I convince you to rediff and resend against the latest 2.6.x snapshot?

At the time you sent these, they conflicted with a previous cleanup you 
had sent, and that I had applied.

	Jeff
