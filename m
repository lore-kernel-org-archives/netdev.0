From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [BUGFIX PATCH 1/2] brcmfmac: Check rtnl_lock is locked when removing interface
Date: Mon, 15 Aug 2016 13:57:52 +0300
Message-ID: <87wpjib8pb.fsf@kamboji.qca.qualcomm.com>
References: <147125403645.9434.8008546579326856373.stgit@devbox>
	<147125405701.9434.12911635695339175773.stgit@devbox>
	<5bb6e373-e110-b1ac-6f65-fdf2f9f059fc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Masami Hiramatsu <mhiramat@kernel.org>,
	Arend van Spriel <arend.vanspriel@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	Hante Meuleman <hante.meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	linux-wireless@vger.kernel.org,
	brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5bb6e373-e110-b1ac-6f65-fdf2f9f059fc@gmail.com>
 (=?utf-8?Q?=22Rafa=C5=82=09Mi=C5=82ecki=22's?= message of "Mon, 15 Aug 2016
 12:41:34 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafał Miłecki <zajec5@gmail.com> writes:

>> Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
>
> Fixes: a63b09872c1d ("brcmfmac: delete interface directly in code that sent fw request")
> Acked-by: Rafał Miłecki <rafal@milecki.pl>
>
> Kalle: I'm acking this as bugfix for 4.8 release.

Ok. I'll wait few days for more comments before I apply this.

(I assume you are talking only about patch 1)

-- 
Kalle Valo
