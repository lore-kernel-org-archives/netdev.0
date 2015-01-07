From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] net: wireless: rt2x00: use helper to check capability/requirement
Date: Wed, 07 Jan 2015 19:52:38 +0200
Message-ID: <87k30yqxzt.fsf@kamboji.qca.qualcomm.com>
References: <1419581958-5927-1-git-send-email-fred.chou.nd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sgruszka@redhat.com, helmut.schaa@googlemail.com,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Fred Chou <fred.chou.nd@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419581958-5927-1-git-send-email-fred.chou.nd@gmail.com> (Fred
	Chou's message of "Fri, 26 Dec 2014 16:19:18 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fred Chou <fred.chou.nd@gmail.com> writes:

> From: Fred Chou <fred.chou.nd@gmail.com>
>
> Use rt2x00_has_cap_flag macro to check rt2x00dev->cap_flags. 
>
> Signed-off-by: Fred Chou <fred.chou.nd@gmail.com>

Thanks, applied to wireless-drivers-next.git. But I simplified the
title:

b9d305cc4740 rt2x00: use helper to check capability/requirement

-- 
Kalle Valo
