From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [patch 03/10] pcnet32: 79c976 with fiber optic fix
Date: Thu, 6 Jan 2005 15:19:56 -0800
Message-ID: <20050106231956.GA22130@us.ibm.com>
References: <200501050559.j055xb614676@mail.osdl.org> <41DDBF72.4000406@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, davem@davemloft.net, netdev@oss.sgi.com, agx@sigxcpu.org,
        lars@segv.dk
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41DDBF72.4000406@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sorry for the delay, I had a nice vacation and am a little slow getting
through the email.

Three comments:

1) I recently obtained a 2701FX card but I haven't installed it in a
system yet, but I will today.

2) Thomas Bogendorfer was working on a patch to support a board with
both a fiber and copper connection on the same board.  He is still
cooking that change, but it changes code in the same place, but in a
different way.

3) I will send another email, later today or tomorrow morning, after I
have been able to do a little testing of the patch.

On Thu, Jan 06, 2005 at 05:45:06PM -0500, Jeff Garzik wrote:
> akpm@osdl.org wrote:
> >From: Guido Guenther <agx@sigxcpu.org>,
> >      Lars Munch <lars@segv.dk>
> >
> >Skip PHY selection on Allied Telesyn 2701FX, it looses the link otherwise. 
> >Fix up the AT 2701 as well.
> >
> >Signed-Off-By: Guido Guenther <agx@sigxcpu.org>
> >Signed-off-by: Andrew Morton <akpm@osdl.org>
> 
> Don, any comments?
> 
> 	Jeff
-- 
Don Fry
brazilnut@us.ibm.com
