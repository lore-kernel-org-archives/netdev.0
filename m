From: Cong Wang <cwang@twopensource.com>
Subject: Re: [patch net-next 2/2] sched: introduce vlan action
Date: Thu, 13 Nov 2014 09:06:13 -0800
Message-ID: <CAHA+R7NaRPzXzpe9K-EnVKdwcDNoBeVA4pPZdD4BTpfDSk5r3w@mail.gmail.com>
References: <1415700789-9171-1-git-send-email-jiri@resnulli.us>
	<1415700789-9171-2-git-send-email-jiri@resnulli.us>
	<CAHA+R7P1PM5=TJYRPPrYc_U4AnLvsgQPZr0coTbeijAUGvB9zg@mail.gmail.com>
	<20141112074755.GA1882@nanopsycho.orion>
	<5463522C.1030104@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	Florian Westphal <fw@strlen.de>, Paul.Durrant@citrix.com,
	Thomas Graf <tgraf@suug.ch>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:56940 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbaKMRGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 12:06:16 -0500
Received: by mail-qc0-f175.google.com with SMTP id b13so12789978qcw.6
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 09:06:15 -0800 (PST)
In-Reply-To: <5463522C.1030104@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2014 at 4:27 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
> Cong,
> I think it is better to have all these "tunneling" activities
> as a separate action each. It is cleaner from a usability perspective.
> [e.g. it is not hard to express nat action with pedit action or take
> checksum out of nat since we have a csum action), but makes sense to
> have it separate)].
>

Sounds good.
