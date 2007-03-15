From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 0/6] IrDA: Updates
Date: Fri, 16 Mar 2007 01:06:26 +0200
Message-ID: <20070315230625.GA3478@sortiz.org>
References: <20070314192236.GB3397@sortiz.org>
	<20070315.030054.78719597.davem@davemloft.net>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070315.030054.78719597.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On Thu, Mar 15, 2007 at 03:00:54AM -0700, David Miller wrote:
> From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
> Date: Wed, 14 Mar 2007 21:22:36 +0200
> 
> > Some IrDA updates:
> > 
> > - IrNET identation and bug fix. (patches 1 and 2)
> > - IrLAP raw mode initial implementation. (patch 3)
> > - stir4200 and irda-usb fixes. (patches 4 and 5)
> > - hashbin lockdep fixes. (patch 6)
> 
> Indentation and coding-style cleanups are not appropriate for 2.6.21,
> so I need to ask you which of these changes you need to get into
> 2.6.21 and which can go into the non-bug-fix 2.6.22 bound tree?
> 
> When you submit a mish-mash of cleanups and real bug fixes,
> it makes life extremely difficult for me, that's why I totally
> abandoned even looking at this today until right before going
> to sleep.
I understand that, sorry about it.


> Please properly segregate things in the future and make sure that you
> submit bug fixes against net-2.6 and features against the net-2.6.22
> tree.
I will resend 2 separate patch sets by tomorrow, forget about this one.

Thanks for your patience.

Cheers,
Samuel.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
