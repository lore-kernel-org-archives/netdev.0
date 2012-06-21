From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: How does SACK or FACK determine the time to start fast
 retransmition?
Date: Thu, 21 Jun 2012 07:59:02 +0200
Message-ID: <1340258342.4604.3983.camel@edumazet-glaptop>
References: <CAAA3+BpRQ24HED6a+yCF+A_q=vJ7nHexLJd1U+-50pb43MVa5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: LovelyLich <lovelylich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAA3+BpRQ24HED6a+yCF+A_q=vJ7nHexLJd1U+-50pb43MVa5w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-06-20 at 22:31 +0800, LovelyLich wrote:
> HI all,
>     When tcp uses reno as its congestion control algothim, it uses
> tp->sacked_out as dup-ack. When the third dup-ack(under default
> condition) comes, tcp will initiate its fast retransmition.
>     But how about sack ?

Some tcp experts out there only catch tcp related stuff if Subject
includes TCP.

You might resend your mail on netdev (not sure lkml will really help)
with following subject :

[RFC] tcp: How does SACK or FACK determine the time to start fast
retransmission?

To get more traction.
