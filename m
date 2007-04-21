From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/7] [IrDA] af_irda: Silence kernel message
 in irda_recvmsg_stream
Date: Sat, 21 Apr 2007 10:43:50 -0700 (PDT)
Message-ID: <20070421.104350.130236274.davem@davemloft.net>
References: <20070418214750.515230054@sortiz.org>
	<20070420.220900.45154094.davem@davemloft.net>
	<20070421120152.GB4337@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, olaf.kirch-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20070421120152.GB4337-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Date: Sat, 21 Apr 2007 15:01:52 +0300

> On Fri, Apr 20, 2007 at 10:09:00PM -0700, David Miller wrote:
> > There were some conflicts in this one wrt. the sock_orphan()
> > bug fix we put into mainline recently, but I did my best
> > to resolve it when I applied this to net-2.6.22
> > 
> > You can have a look and verify things when I put up my net-2.6.2
> > tree later this evening.
> Verified. It's all good, thanks a lot.

Thanks for checking.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
