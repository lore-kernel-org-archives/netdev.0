From: Vincent Bernat <bernat@luffy.cx>
Subject: Re: [PATCH] net: ethtool: don't require CAP_NET_ADMIN for ETHTOOL_GLINKSETTINGS
Date: Sun, 25 Dec 2016 08:44:40 +0100
Message-ID: <87tw9s311z.fsf@luffy.cx>
References: <20161124095506.25791-1-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, David Decotigny <decot@googlers.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:51584 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752682AbcLYHxT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Dec 2016 02:53:19 -0500
In-Reply-To: <20161124095506.25791-1-mlichvar@redhat.com> (Miroslav Lichvar's
        message of "Thu, 24 Nov 2016 10:55:06 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 24 novembre 2016 10:55 +0100, Miroslav Lichvar <mlichvar@redhat.=
com>=C2=A0:

> The ETHTOOL_GLINKSETTINGS command is deprecating the ETHTOOL_GSET
> command and likewise it shouldn't require the CAP_NET_ADMIN
> capability.

Could this patch be pushed to stable branches too?
--=20
Each module should do one thing well.
            - The Elements of Programming Style (Kernighan & Plauger)
