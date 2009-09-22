From: Alexandre Cassen <acassen@freebox.fr>
Subject: Re: [PATCH][RESEND 2] IPv6: 6rd tunnel mode
Date: Tue, 22 Sep 2009 22:55:37 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.0909222254120.22622@lnxos.staff.proxad.net>
References: <20090922085105.GA20906@lnxos.staff.proxad.net> <20090922.134543.158902222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:36116 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752696AbZIVUzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2009 16:55:41 -0400
In-Reply-To: <20090922.134543.158902222.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 22 Sep 2009, David Miller wrote:

> From: Alexandre Cassen <acassen@freebox.fr>
> Date: Tue, 22 Sep 2009 10:51:05 +0200
>
>> IPv6 rapid deployment (RFC5569) builds upon mechanisms of 6to4 (RFC3056)
>> to enable a service provider to rapidly deploy IPv6 unicast service
>> to IPv4 sites to which it provides customer premise equipment.  Like
>
> I've read your explanation, but it is still presumptious to mention
> an RFC number before it isn't really released yet.
>
> Mention the drafts only, and when it achieves true RFC status
> you can send another patch updating those references in the
> code comments.

ack. will fix this and resend.
