From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 01 Aug 2003 18:35:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2AEB33.9050506@pobox.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>	<20030801154021.GA7696@gtf.org>	<20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>	<20030801162536.GA18574@gtf.org> <20030801132037.3f3542ae.davem@redhat.com> <3F2AE91D.5090705@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <3F2AE91D.5090705@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> It's an explicit goal to avoid changing the driver API in such a way 
> that there is a remotely sane path to supporting older kernels. 


I, of course, meant the exact opposite here :)

We want to provide a sane, ifdef-free path to kcompat, where feasible.
