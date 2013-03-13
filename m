From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] packet: packet fanout rollover during socket overload
Date: Wed, 13 Mar 2013 12:13:58 -0400
Message-ID: <CA+FuTScE_Y-waWVKRzJZuovbXdOmRQ3wHxjDETpjiwKwRvrbuQ@mail.gmail.com>
References: <1363100153-24433-1-git-send-email-willemb@google.com>
 <20130313.044405.628402628153303315.davem@davemloft.net> <20130313.044544.792587152137191597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:50349 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932658Ab3CMQO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 12:14:29 -0400
Received: by mail-ia0-f174.google.com with SMTP id k38so1114074iah.5
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 09:14:28 -0700 (PDT)
In-Reply-To: <20130313.044544.792587152137191597.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 13, 2013 at 4:45 AM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 13 Mar 2013 04:44:05 -0400 (EDT)
>
>>
>> My kingdom for a proper signoff.
>
> Nevermind I see you did this in the second copy you posted.
>
> Please mention that such things have changed below the "---"
> seperator so that people can know instead of just guess.

Will do. Apologies for the botched emails, including the html reply
that the list thankfully rejected. I'll write some fanout
documentation for the packet man page as penance.
