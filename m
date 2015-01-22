From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Thu, 22 Jan 2015 10:28:03 -0500
Message-ID: <54C11703.7030702@mojatatu.com>
References: <20150120202404.1741.8658.stgit@nitbit.x32> <20150122125246.GA4486@salvia> <20150122133713.GA25797@casper.infradead.org> <20150122140022.GA5674@salvia> <54C11094.2000807@mojatatu.com> <20150122151316.GB25797@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com, Jiri Pirko <jiri@resnulli.us>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:64396 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbbAVP2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 10:28:07 -0500
Received: by mail-ie0-f174.google.com with SMTP id vy18so1919335iec.5
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 07:28:05 -0800 (PST)
In-Reply-To: <20150122151316.GB25797@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/15 10:13, Thomas Graf wrote:

> I don't follow this. John's proposal allows to decide on a case by
> case basis what we want to export. Just like with ethtool or
> RTNETLINK. There is no direct access to hardware. A user can only
> configure what is being exposed by the kernel.
>

So if i am a vendor with my own driver, I can expose whatever i want.
Only my SDK needs to deal with what i expose. There is no needed
feature in the kernel other than the driver exposing it that is
required.

cheers,
jamal
