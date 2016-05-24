From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute2 1/1] tc simple action: bug fix
Date: Tue, 24 May 2016 12:30:24 +0200
Message-ID: <57442D40.4040905@iogearbox.net>
References: <1464051893-25680-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50298 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253AbcEXKa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 06:30:28 -0400
In-Reply-To: <1464051893-25680-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2016 03:04 AM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Failed compile
> m_simple.c: In function =E2=80=98parse_simple=E2=80=99:
> m_simple.c:154:6: warning: too many arguments for format [-Wformat-ex=
tra-args]
>        *argv);
>        ^
> m_simple.c:103:14: warning: unused variable =E2=80=98maybe_bind=E2=80=
=99 [-Wunused-variable]

Btw, that last one is still not addressed.
