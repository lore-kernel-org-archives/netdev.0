From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: echo > 0 .../disable_ipv6 broken in 2.6.37-rc4
Date: Sun, 05 Dec 2010 16:39:10 -0800
Message-ID: <m1zksjka4x.fsf@fess.ebiederm.org>
References: <m17hfnlpe1.fsf@fess.ebiederm.org>
	<AANLkTin4hO63J4thByJeG2SiGHn9ZqsbWKy1p_TEfeu_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Brian Haley <brian.haley@hp.com>,
	Mahesh Kelkar <maheshkelkar@gmail.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42658 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224Ab0LFAjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 19:39:15 -0500
In-Reply-To: <AANLkTin4hO63J4thByJeG2SiGHn9ZqsbWKy1p_TEfeu_@mail.gmail.com>
	(Lorenzo Colitti's message of "Sun, 5 Dec 2010 16:33:46 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lorenzo Colitti <lorenzo@google.com> writes:

> On Sun, Dec 5, 2010 at 4:24 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
>> In 2.6.37-rc4 ipv6 can be disabled not enabled.
>> The last kernel I have tested and know this works on is 2.6.33.
>
> I'm pretty sure I could successfully re-enable IPv6 on non-loopback
> interfaces (wlan0, eth0) on net-2.6 pulled a little after 2.6.37-rc1.
> I didn't try lo though. Does re-enabling IPv6 on a "real" interface
> still work?

Interesting that case seems to work.

Eric

