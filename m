From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [netfilter / iptables] question
Date: Thu, 1 Apr 2010 18:57:50 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1004011857440.788@obet.zrqbmnf.qr>
References: <v2if4f837ab1004010944yd08c37c5u23d6f2d07df7ccc6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: thomas yang <lampsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:42234 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752988Ab0DAQ5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 12:57:51 -0400
In-Reply-To: <v2if4f837ab1004010944yd08c37c5u23d6f2d07df7ccc6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 2010-04-01 18:44, thomas yang wrote:

>Hi,
>
>I want to copy/ clone a  sk_buff  *skb  to  *skb2  on my Linux router,
>  then transmit both  skb2   and  skb  .
>
>How to do this with   netfilter hook function  / iptables  ?
>
Wait for xt_TEE to be merged.
