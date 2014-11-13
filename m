From: Cong Wang <cwang@twopensource.com>
Subject: Re: [patch net-next v2 4/4] sched: introduce vlan action
Date: Thu, 13 Nov 2014 09:07:46 -0800
Message-ID: <CAHA+R7PvqPQR1CqKFfWhRRtwkjs6ymfSYUwBoXSess8G0pTGSg@mail.gmail.com>
References: <1415803950-9838-1-git-send-email-jiri@resnulli.us>
	<1415803950-9838-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	Florian Westphal <fw@strlen.de>, Paul.Durrant@citrix.com,
	Thomas Graf <tgraf@suug.ch>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:40509 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbaKMRHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 12:07:47 -0500
Received: by mail-qc0-f169.google.com with SMTP id i17so11671217qcy.28
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 09:07:46 -0800 (PST)
In-Reply-To: <1415803950-9838-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2014 at 6:52 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> This tc action allows to work with vlan tagged skbs. Two supported
> sub-actions are header pop and header push.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Reviewed-by: Cong Wang <cwang@twopensource.com>
