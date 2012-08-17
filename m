From: Ulrich Weber <ulrich.weber@sophos.com>
Subject: Re: [PATCH net-next] sctp: fix compile issue with disabled CONFIG_NET_NS
Date: Fri, 17 Aug 2012 14:07:51 +0200
Message-ID: <502E3417.9070602@sophos.com>
References: <20120816112449.GA17354@uweber-WS> <87fw7m64v9.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.sophos.com ([216.47.234.213]:44972 "EHLO mx4.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754143Ab2HQMPz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2012 08:15:55 -0400
In-Reply-To: <87fw7m64v9.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On 08/16/2012 08:58 PM, Eric W. Biederman wrote:
> Ulrich do you get any performance advantage by disabling the network=20
> namespace? I am wondering if there is any benefit to keeping it=20
> possible to disable the network namespace? The original reason for th=
e=20
> option was so that distributions and other who wanted to avoid new=20
> code could protect their users, and that reasons seems to have long=20
> since passed.
we just disable most of the options we don't use. I have no idea,
if there are any performance advantages here...

Cheers
Ulrich

--=20
Ulrich Weber | ulrich.weber@sophos.com | Senior Software Engineer
Astaro - a Sophos company | Amalienbadstr 41 | 76227 Karlsruhe | German=
y
Phone +49-721-25516-0 | Fax =96200 | www.astaro.com
