From: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Subject: Re: [PATCH] rfkill: document removal of notifier chain
Date: Wed, 08 Apr 2009 18:21:50 +0100
Message-ID: <49DCDD2E.80705@tuffmail.co.uk>
References: <49DCA88E.6060400@tuffmail.co.uk>	 (sfid-20090408_153722_059382_FB44D658) <1239204090.16477.1.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Ivo van Doorn <IvDoorn@gmail.com>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:44646 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601AbZDHRVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 13:21:55 -0400
Received: by fg-out-1718.google.com with SMTP id 16so574786fgg.17
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2009 10:21:52 -0700 (PDT)
In-Reply-To: <1239204090.16477.1.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
> On Wed, 2009-04-08 at 14:37 +0100, Alan Jenkins wrote:
>   
>> This unused feature was removed in 4dec9b807be757780ca3611a959ac22c28d292a7
>>
>> Signed-off-by: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
>> ---
>>
>> p.s. Is netdev really the right list for rfkill (as listed in MAINTAINERS)?
>>      I have a feeling most development happens on linux-wireless.
>>     
>
> You're right, and I'm rewriting rfkill and part of that is changing the
> maintainer to myself and the list to linux-wireless.
>   

Good luck!  I'll try to have a look at your patch, to see how (if) it
would affect the benighted eeepc-laptop.

> I have no problems with this patch, but note that I'm rewriting that
> entire file as well so it's not really necessary in the long run -- now
> that -rc1 is out I can hopefully convert all in-tree rfkill stuff and
> get the patch in.
>   

Heh, ok.

Alan
