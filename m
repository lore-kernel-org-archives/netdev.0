From: Shlomo Pongartz <shlomop@mellanox.com>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Wed, 25 Jul 2012 17:38:22 +0300
Message-ID: <501004DE.6050300@mellanox.com>
References: <1342814143-5744-1-git-send-email-klebers@linux.vnet.ibm.com> <20120724.140353.1432900101600410863.davem@davemloft.net> <CAJZOPZKUw7DQQH5mFq4XK5GOZ_Wj6JmjFYi6no7aL_UrpO10vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <klebers@linux.vnet.ibm.com>,
	<netdev@vger.kernel.org>, <jackm@dev.mellanox.co.il>,
	<yevgenyp@mellanox.co.il>, <ogerlitz@mellanox.com>,
	<cascardo@linux.vnet.ibm.com>, <brking@linux.vnet.ibm.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:48353 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933148Ab2GYOip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 10:38:45 -0400
In-Reply-To: <CAJZOPZKUw7DQQH5mFq4XK5GOZ_Wj6JmjFYi6no7aL_UrpO10vw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/25/2012 1:30 AM, Or Gerlitz wrote:
> On Wed, Jul 25, 2012 at 12:03 AM, David Miller <davem@davemloft.net> wrote:
>
>> Or, you promised an ACK today, I still haven't seen it.
> It turned out that reacted we did, but not the ACK way.
>
> Again, code review wise, we intended to ack it, but Shlomo has set
> testing environment, under which he had some issues with the patch, as
> such he preferred not to ACK it but rather bring up the issues on the
> list and sort them out 1st. I thought it would be wrong to over-rule
> this preference of him, and this way is fair-enough with the author
> and your guide-lines, maybe I had to be more aggressive with ACKing
> this, as of the merge window closing coming. So tomorrow.
>
> Or.
>
>> There is no reason Kleber should be penalized and have his work
>> miss the merge window just because you guys can't be bothered
>> to approve this patch in a reasonable amount of time.
>>
>> Therefore I'm just going to apply it later today, and don't do this
>> with someone's submission ever again, it impedes progress and
>> frustrates contributors.
> .
>
The code looks fine and can be merged.
We will continue to test it under various conditions.
Sorry for the delay.
Thank you.
Shlomo Pongratz.
