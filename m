From: "Tobias Koeck" <tobias.koeck@gmail.com>
Subject: meant hlist_* - Re: hash_list and rcu locking question
Date: Thu, 7 Aug 2008 03:49:43 +0200
Message-ID: <379e30200808061849w3a47f981s5ccde245059f595b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:59881 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755016AbYHGBto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 21:49:44 -0400
Received: by fg-out-1718.google.com with SMTP id 19so119684fgg.17
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 18:49:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I mean the rcu function for the hlist_{head,list} ....

Greetings
t.

On Wed, Aug 6, 2008 at 10:54 PM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> Hi Tobias.
>
> On Wed, Aug 06, 2008 at 05:56:43PM +0200, Tobias Koeck (tobias.koeck@gmail.com) wrote:
>> Are the hash_list rcu functions avoiding all locking problems (even
>> the one with only one CPU)?
>
> What is hash list? hlist? Or list in a hash bucket?
> Does include/linux/rculist.h contain needed bits?
>
>> Are there some abstract examples for the use of the hash_{head,list} structures?
>
> Sorry, my kernel source tree does not know what is 'hash_head'.
> What data structure exactly do you mean?
>
> --
>        Evgeniy Polyakov
>
