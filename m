From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC ethtool usage
Date: Thu, 5 May 2005 20:01:08 -0700
Message-ID: <20050505200108.1e45f860.davem@davemloft.net>
References: <20050505234128.GA21736@us.ibm.com>
	<427AD74B.10904@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brazilnut@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <427AD74B.10904@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 05 May 2005 22:32:43 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Convenient in the short term, but misleading in the long run, IMO.
> 
> Surely you can get this info from an ethtool register dump?

I agree.  It might not be a bad idea to formalize this in some
generic "ethtool_chip_info" block, however.
