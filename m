From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 00/11] Gigaset driver patches for 2.6.32 (v3)
Date: Tue, 06 Oct 2009 23:39:01 -0700 (PDT)
Message-ID: <20091006.233901.192206610.davem@davemloft.net>
References: <20091006-patch-gigaset-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        isdn4linux-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org, hjlipp-S0/GAf8tV78@public.gmane.org, keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
To: tilman-ZTO5kqT2PaM@public.gmane.org
Return-path: <isdn4linux-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
In-Reply-To: <20091006-patch-gigaset-00.tilman-ZTO5kqT2PaM@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/listinfo/isdn4linux>,
	<mailto:isdn4linux-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/isdn4linux>
List-Post: <mailto:isdn4linux-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:isdn4linux-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/isdn4linux>,
	<mailto:isdn4linux-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: isdn4linux-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: isdn4linux-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Date: Wed,  7 Oct 2009 00:18:21 +0200 (CEST)

> This is the third release of the series of patches for the Gigaset
> drivers I first submitted on 2009-09-06. I have dropped the first patch
> "gigaset: really fix chars_in_buffer" because it has now been merged
> through the tty tree, and folded into the last one the fixes I posted on
> 2009-09-25 and 2009-10-01. Apart from that, the series is unchanged from
> the second submission on 2009-09-19. It would be great if this could
> still make it into release 2.6.32 as one more step on the way to get rid
> of the deprecated ISDN4Linux subsystem.

I applied patches 1-8 to net-2.6, merged net-2.6 into net-next-2.6,
then added patches 9-11 into net-next-2.6

Thanks!
