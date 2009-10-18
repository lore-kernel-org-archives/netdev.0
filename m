From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net: Fix RPF to work with policy routing
Date: Sun, 18 Oct 2009 08:13:39 -0400
Message-ID: <1255868019.4815.27.camel@dogo.mojatatu.com>
References: <1255867954.4815.25.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Atis Elsts <atis@mikrotik.com>,
	eric.dumazet@gmail.com,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:36476 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbZJRMQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 08:16:40 -0400
Received: by qyk32 with SMTP id 32so2428959qyk.4
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 05:16:45 -0700 (PDT)
In-Reply-To: <1255867954.4815.25.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-10-18 at 08:12 -0400, jamal wrote:
> policy routing never worked with mark.

I meant policy routing, mark and RPF never worked together ;->

cheers,
jamal

