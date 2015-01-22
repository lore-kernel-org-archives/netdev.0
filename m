From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Thu, 22 Jan 2015 10:44:12 -0500
Message-ID: <54C11ACC.5010005@mojatatu.com>
References: <20150120202404.1741.8658.stgit@nitbit.x32> <20150122125246.GA4486@salvia> <20150122133713.GA25797@casper.infradead.org> <20150122140022.GA5674@salvia> <54C11094.2000807@mojatatu.com> <20150122151316.GB25797@casper.infradead.org> <54C11703.7030702@mojatatu.com> <20150122153727.GC25797@casper.infradead.org>
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
Received: from mail-ie0-f173.google.com ([209.85.223.173]:35820 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbbAVPoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 10:44:15 -0500
Received: by mail-ie0-f173.google.com with SMTP id tr6so2003415ieb.4
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 07:44:14 -0800 (PST)
In-Reply-To: <20150122153727.GC25797@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/15 10:37, Thomas Graf wrote:
> On 01/22/15 at 10:28am, Jamal Hadi Salim wrote:

>> So if i am a vendor with my own driver, I can expose whatever i want.
>
> No. We will reject any driver change attempting to do so on this
> list.
>

Vendor provides a driver that exposes a discoverable interface
(capabilities exposure that is facilitated).
They dont need it to be part of the mainstream kernel.
And they dont need any of your definitions.

cheers,
jamal
