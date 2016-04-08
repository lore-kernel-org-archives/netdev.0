From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH] net: thunderx: Fix broken of_node_put() code.
Date: Fri, 8 Apr 2016 13:34:26 -0700
Message-ID: <570815D2.5050608@caviumnetworks.com>
References: <1459472517-5696-1-git-send-email-ddaney.cavm@gmail.com> <5707DF3F.3000508@caviumnetworks.com> <20160408.161557.850174112269792582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ddaney.cavm@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <rric@kernel.org>,
	<sgoutham@cavium.com>, <david.daney@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160408.161557.850174112269792582.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/08/2016 01:15 PM, David Miller wrote:
> From: David Daney <ddaney@caviumnetworks.com>
> Date: Fri, 8 Apr 2016 09:41:35 -0700
>
>> Due to mail server malfunction, this patch was sent twice.  Please
>> ignore this duplicate.
>
> This submission had another problem too.
>
> Do not use the date of your commit as the date that gets put into
> your email headers.

I don't.  This is standard git-send-email 1.7.11.7.


>
> This makes all of your patch submissions look like they occurred in
> the past, and this mixes up the ordering of patches in patchwork.


They did occur in the past.  Just like all e-mail you read, they were 
sent before you read them.

I ran git-send-email for this on  Thu, 31 Mar 2016 18:01:57 -0700.  I 
observed that the patch didn't seem to make it to the public lists, so I 
figured I screwed something up and I sent it again, with the same results.

Then I went on vacation, and came back today to sort everything out.  My 
MTA had died, so I restarted it, and ... the backlog of messages was 
sent and you read it.


>
> So please resubmit this properly with a normal, current, date in your
> email headers.

OK, I will resend the identical patch for the third time...
