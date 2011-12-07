From: Timur Irmatov <irmatov@gmail.com>
Subject: Re: atl1c: WARNING: at net/sched/sch_generic.c:255 dev_watchdog
Date: Wed, 7 Dec 2011 15:25:59 +0500
Message-ID: <CACV5A19cwzAfzY3iXD6uN8A79LTTsPUaVJQqiazLqAACpEfYmQ@mail.gmail.com>
References: <20111206232741.GA5368@x1.osrc.amd.com>
	<CA+5PVA7bM8ZGaCiyZdHcMVccJYh2=bk-gsHLo9ZmBP_SYT208w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:62098 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825Ab1LGK0A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 05:26:00 -0500
Received: by qadb40 with SMTP id b40so3145981qad.19
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2011 02:26:00 -0800 (PST)
In-Reply-To: <CA+5PVA7bM8ZGaCiyZdHcMVccJYh2=bk-gsHLo9ZmBP_SYT208w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 7, 2011 at 5:12 AM, Josh Boyer <jwboyer@gmail.com> wrote:
> Matthew Garrett has a patch to the atl1c driver that changed it's ASP=
M
> behavior that seemed to help. =C2=A0Dave Miller applied it, but I don=
't see
> it in linux-next for some reason.
>
> http://comments.gmane.org/gmane.linux.kernel/1214694

May be this is the reason?

http://article.gmane.org/gmane.linux.kernel/1215132/

I'm also having this issue and can test patches.


--=20
Timur Irmatov, xmpp:irmatov@jabber.ru
