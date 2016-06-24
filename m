From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Fri, 24 Jun 2016 14:36:04 -0700
Message-ID: <576DA7C4.7040108@hpe.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
 <CAFLxGvwmhTv0rTuDpg7r1vZ0GEU93j1QxV12mJ2c2W2qSJGRCQ@mail.gmail.com>
 <20160623.034004.1518087003165708123.davem@davemloft.net>
 <576B94DA.7070804@nod.at>
 <CALx6S35ii7nF0s9n2ocpvNcjo25uDHd+788X+3oTqc4sd1SjOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>,
	Richard Weinberger <richard@nod.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2355.austin.hpe.com ([15.233.44.28]:25385 "EHLO
	g2t2355.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446AbcFXVgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 17:36:06 -0400
In-Reply-To: <CALx6S35ii7nF0s9n2ocpvNcjo25uDHd+788X+3oTqc4sd1SjOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2016 02:12 PM, Tom Herbert wrote:
> The client OS side is only part of the story. Middlebox intrusion at
> L4 is also a major issue we need to address. The "failure" of TFO is a
> good case study. Both the upgrade issues on clients and the tendency
> for some middleboxes to drop SYN packets with data have together
> severely hindered what otherwise should have been straightforward and
> useful feature to deploy.

How would you define "severely?"  Has it actually been more severe than 
for say ECN?  Or it was for say SACK or PAWS?

rick jones
