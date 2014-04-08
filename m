From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net v2] net: sctp: wake up all assocs if sndbuf policy
 is per socket
Date: Tue, 08 Apr 2014 19:20:16 +0200
Message-ID: <53442FD0.5020609@redhat.com>
References: <1396970773-17500-1-git-send-email-dborkman@redhat.com> <53442A62.3050905@redhat.com> <20140408.131819.1373401078750444800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org, tgraf@suug.ch,
	nhorman@tuxdriver.com, vyasevic@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51677 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757128AbaDHSOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2014 14:14:30 -0400
In-Reply-To: <20140408.131819.1373401078750444800.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2014 07:18 PM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Tue, 08 Apr 2014 18:57:06 +0200
>
>> Hm, I still found an issue, please hold on with this one, thanks.
>
> Ugh too late I pushed it out, you'll need to send a relative fix.

No problem, will do, thanks. I suggest to take it out from
the stable queue for now. Sorry for any inconvenience.
