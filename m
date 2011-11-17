From: David Decotigny <david.decotigny@google.com>
Subject: Re: [PATCH net-next v6 3/9] kbuild: document RPS/XPS network Kconfig options
Date: Wed, 16 Nov 2011 19:04:58 -0800
Message-ID: <CAG88wWYgUkStZk988iWzbWf_=1Ze-Rtvs82sMrZoeuFPQphaUA@mail.gmail.com>
References: <cover.1321496595.git.david.decotigny@google.com>
 <e0bb736123d687a921f15e4bb0254eeeabe22dcb.1321496595.git.david.decotigny@google.com>
 <20111116.215808.299077226767455988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ian.campbell@citrix.com, eric.dumazet@gmail.com,
	jeffrey.t.kirsher@intel.com, bhutchings@solarflare.com,
	jpirko@redhat.com, joe@perches.com, szymon@janc.net.pl,
	rick.jones2@hp.com, AAbdulla@nvidia.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:46338 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755466Ab1KQDFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 22:05:21 -0500
Received: by ywt32 with SMTP id 32so497446ywt.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 19:05:20 -0800 (PST)
In-Reply-To: <20111116.215808.299077226767455988.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2011 at 6:58 PM, David Miller <davem@davemloft.net> wrote:
> From: David Decotigny <david.decotigny@google.com>
> Date: Wed, 16 Nov 2011 18:39:05 -0800
>
>> This adds a description of RPS/XPS options and allow them to be
>> changed at make menuconfig time.
>
> These aren't meant to be selectable.

Ok. I only needed this for our compilation scripts in order to make
sure I didn't have my CONFIG_* wrong in patch 4/9. I don't need this
patch anymore.

David, should I re-send an updated v7 version of this series with this
patch removed? Or is it Ok if I simply mark this patch as rejected in
patchwork and stick to patch series v6?
