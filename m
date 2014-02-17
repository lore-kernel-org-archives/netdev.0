From: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Subject: Re: [PATCH net 0/3] pf_packet fix
Date: Mon, 17 Feb 2014 07:59:36 +0100
Message-ID: <5301B358.6030701@fokus.fraunhofer.de>
References: <1392562522-15585-1-git-send-email-dborkman@redhat.com> <20140217.004915.457539963937571200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <brouer@redhat.com>, <netdev@vger.kernel.org>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: David Miller <davem@davemloft.net>, <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-relay04-dus.antispameurope.com ([94.100.134.204]:45456 "EHLO
	mx-relay04-dus.antispameurope.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751626AbaBQHAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 02:00:14 -0500
In-Reply-To: <20140217.004915.457539963937571200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2014 06:49 AM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Sun, 16 Feb 2014 15:55:19 +0100
>
>> Addressed all feedback from Dave and reworked the original patch
>> from [1]. Set is intended for 3.14.
>
> Looks great, series applied, thanks Daniel.
>

Initial feedback (linux-3.14-rc3 + your patches):
The WARNING from within 80211 is gone.

A more extensive evaluation is still pending.

Thanks,

Mathias
