From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: netlink permission checks for -stable
Date: Wed, 18 Jun 2014 20:25:00 -0700
Message-ID: <87zjh9mvhv.fsf@x220.int.ebiederm.org>
References: <20140617.222309.545580698366469088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, luto@amacapital.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:36982 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674AbaFSD0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 23:26:14 -0400
In-Reply-To: <20140617.222309.545580698366469088.davem@davemloft.net> (David
	Miller's message of "Tue, 17 Jun 2014 22:23:09 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> I was able to do the backporting for everything back to v3.10
> but for v3.2 and v3.4 it was beyond my means.
>
> Could you guys help me out and do backport of mainline commits:
>
> 5187cd055b6e81fc6526109456f8b20623148d5f
> a53b72c83a4216f2eb883ed45a0cbce014b8e62d
> a3b299da869d6e78cf42ae0b1b41797bcb8c5e4b
> aa4cf9452f469f16cea8c96283b641b4576d4a7b
> 90f62cf30a78721641e08737bda787552428061e
> 2d7a85f4b06e9c27ff629f07a524c48074f07f81
>
> for v3.2 and v3.4 -stable?  Thanks!

I can certainly help review.  However I am not in a place where I can
promise any timely work on this.

Eric
