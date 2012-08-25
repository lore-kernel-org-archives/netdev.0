From: =?UTF-8?B?Q3Jpc3RpYW4gUm9kcsOtZ3Vleg==?= <crrodriguez@opensuse.org>
Subject: Re: BUG: soft lockup - CPU#6 stuck for 22s! [httpd2-event:15597]
Date: Sat, 25 Aug 2012 13:45:51 -0400
Message-ID: <50390F4F.3000404@opensuse.org>
References: <5038215E.60403@opensuse.org>  <1345885186.19483.109.camel@edumazet-glaptop>  <1345886085.19483.141.camel@edumazet-glaptop> <1345895225.19483.447.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Florian Schmitz <floele@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50712 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab2HYRrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 13:47:09 -0400
Received: by pbbrr13 with SMTP id rr13so5241980pbb.19
        for <netdev@vger.kernel.org>; Sat, 25 Aug 2012 10:47:08 -0700 (PDT)
In-Reply-To: <1345895225.19483.447.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 25/08/12 07:47, Eric Dumazet escribi=C3=B3:
> On Sat, 2012-08-25 at 11:14 +0200, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> On Sat, 2012-08-25 at 10:59 +0200, Eric Dumazet wrote:
>>> On Fri, 2012-08-24 at 20:50 -0400, Cristian Rodr=C3=ADguez wrote:
>>>> Hi, the issue I reported with IPV6 few weeks ago seems to be gone,=
 but
>>>> now I am getting the following crash..
>>
>>> Oh, I now see the bug, I'll send a patch asap
>>
>> Please try the following fix.
>>
>> Thanks !

Eric, thanks for your work, I have deployed the fix in one machine and
will keep an eye for any other anomaly.

As it happends around twice a day, it would take a while to determine i=
f
this issue has gone away.

Keep up great work :-)
