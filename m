From: James Morris <jmorris@intercode.com.au>
Subject: Re: rtnetlink interface state monitoring problems.
Date: Mon, 21 Oct 2002 23:48:03 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210212346480.29169-100000@blackbird.intercode.com.au>
References: <Mutt.LNX.4.44.0210212342070.29133-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <Mutt.LNX.4.44.0210212342070.29133-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 21 Oct 2002, James Morris wrote:

> Andi Kleen implemented a simple and effective workaround this for 2.4
> which has gone into the tree (see netlink_set_nonroot() in rtnetlink.c).  
> 

Forgot to add that it might be possible to get Andi's solution into 2.6.


- James
-- 
James Morris
<jmorris@intercode.com.au>
