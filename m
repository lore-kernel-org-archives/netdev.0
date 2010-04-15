From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2 resend] igb: dobule increment nr_frags
Date: Thu, 15 Apr 2010 11:03:50 -0700
Message-ID: <k2u9929d2391004151103xb72e4a78x4ba495bad6df02d9@mail.gmail.com>
References: <4BC6D705.80601@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	davem@davemloft.net, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, john.ronciak@intel.com,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:55758 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755195Ab0DOSDv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 14:03:51 -0400
Received: by pwj9 with SMTP id 9so1370504pwj.19
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 11:03:50 -0700 (PDT)
In-Reply-To: <4BC6D705.80601@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 02:06, Koki Sanagi <sanagi.koki@jp.fujitsu.com>=
 wrote:
> Previous patch has some mail format problem.
> Maybe I've fixed and re-sent.
>
> There is no need to increment nr_frags becasue skb_fill_page_desc inc=
rements
> it.
>
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> ---
> =C2=A0drivers/net/igb/igb_main.c | =C2=A0 =C2=A02 +-
> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>

Thanks, I have added the patch to my queue of patches.

--=20
Cheers,
Jeff
