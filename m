From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net] ipv6: stop sending PTB packets for MTU < 1280
Date: Mon, 19 Jan 2015 15:00:21 +0100
Message-ID: <CAPh34mc3T7W81J_NjMkHvQpjad1gTM3j99gnX8x8jnKvh2TBDg@mail.gmail.com>
References: <1421357665-2804-1-git-send-email-hagen@jauu.net>
	<1421675722.32277.3.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, stable@vger.kernel.org,
	Fernando Gont <fgont@si6networks.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:64387 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbbASOAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 09:00:23 -0500
Received: by mail-la0-f52.google.com with SMTP id hs14so28879823lab.11
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 06:00:21 -0800 (PST)
In-Reply-To: <1421675722.32277.3.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19 January 2015 at 14:55, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>
> I think this is the correct way forward on how to deal with atomic
> fragments.
>
> Hagen, do you submit patches to remove dst_allfrag/RTAX_FEATURE_ALLFRAG,
> IPCORK_ALLFRAG, etc. for net-next, too?

Yes, patch sits already in the pipe. I wanted to wait for davem's pull.

Hagen
