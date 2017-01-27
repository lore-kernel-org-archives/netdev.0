From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 6/6] wl1251: Set generated MAC address back to NVS data
Date: Fri, 27 Jan 2017 09:56:09 +0200
Message-ID: <87inp1ndgm.fsf@codeaurora.org>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
        <1482598381-16513-7-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:52034 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754202AbdA0H4Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 02:56:25 -0500
In-Reply-To: <1482598381-16513-7-git-send-email-pali.rohar@gmail.com> ("Pali
        \=\?utf-8\?Q\?Roh\=C3\=A1r\=22's\?\= message of "Sat, 24 Dec 2016 17:53:01 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:

> In case there is no valid MAC address kernel generates random one. This
> patch propagate this generated MAC address back to NVS data which will be
> uploaded to wl1251 chip. So HW would have same MAC address as linux kernel
> uses.
>
> Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>

Why? What issue does this fix?

--=20
Kalle Valo
