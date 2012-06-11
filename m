From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: Re: [PATCH net-next 0/4] 6lowpan: set of bug fixes
Date: Mon, 11 Jun 2012 16:45:02 +0200
Message-ID: <ce01fc3b60f428ee9d3928d0fca6227c@amnesiak.org>
References: <20120611003741.27263005@dualbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <alex.bluesman.smirnov@gmail.com>
To: <netdev@vger.kernel.org>,
	<linux-zigbee-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:57603 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755116Ab2FKOn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 10:43:28 -0400
In-Reply-To: <20120611003741.27263005@dualbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

As Jan pointed out, it seems that the third patch of my patchset is not=
=20
formatted properly. Moreover, I got my own email address wrong. Please=20
disregard the whole patchset as I need to investigate the issue. I'll=20
repost the complete patchset when it will be resolved.

I'm sorry if it caused any of you to waste your time on it.

Regards,
Tony

Le 11.06.2012 06:37, Tony Cheneau a =C3=A9crit=C2=A0:
> Hello,
>
> (This is my first time submitting patches. If I fail to apply to
> some rules in here, please let me know)
>
> After reading the 6lowpan code, I found a few issues. This patchset
> fixes them. This patchset should apply cleanly against the current
> net-next. It contains only bug fixes, I'll send later on a few other
> patches that will offer new functionalities.
>
> This is a set of 4 small patches that correct bugs in 6lowpan:
> - patch 1 fixes a potential crash when reassembling UDP fragments
> - patch 2 fixes a type issues that prevent the fragmentation=20
> reassembly
>   to operate properly.
> - patch 3 and 4 corrects field encoding issues
>
> Hope it helps.
>
> Regards,
> 	Tony Cheneau
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
