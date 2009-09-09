From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Subject: Re: [PATCH 00/12] Gigaset driver patches for 2.6.32
Date: Thu, 10 Sep 2009 00:32:00 +0200
Message-ID: <200909092232.n89MW6fI011424@listserv.isdn4linux.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Walker <dwalker-zu3NM2574RrQT0dZR+AlfA@public.gmane.org>
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

Daniel Walker wrote 07.09.09 16:30:
> Yeah, it looks like the whole file needs a checkpatch clean up.. Sounds
like your not willing to do that?

It's not a question of willingness. You may notice I did a lot of cleanup work already. But it's very time consuming work, and there has been more important work to attend to first.

> Usually if a checkpatch cleanup comes
first prior to all your other changes , it doesn't usually cloud the
rest of the changes..

Sure. But that would mean postponing the merging of bugfixes until someone finds the time to do a complete checkpatch cleanup of the affected code. I don't think that's a sensible approach.

Thanks,
Tilman
