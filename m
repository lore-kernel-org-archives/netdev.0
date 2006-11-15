From: "Udayan Singh" <udayan.singh@gmail.com>
Subject: Re: Setup of testing lab and work on development
Date: Thu, 16 Nov 2006 02:34:29 +0530
Message-ID: <d9a09df00611151304l11d089b5w958788ec24fc6af0@mail.gmail.com>
References: <d9a09df00611150857i3ac7e35cr84dd61cfd55f5b4e@mail.gmail.com>
	 <1163614554.5399.112.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:47406 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1030994AbWKOVEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Nov 2006 16:04:30 -0500
Received: by wx-out-0506.google.com with SMTP id s7so364723wxc
        for <netdev@vger.kernel.org>; Wed, 15 Nov 2006 13:04:30 -0800 (PST)
To: "Johannes Berg" <johannes@sipsolutions.net>
In-Reply-To: <1163614554.5399.112.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/15/06, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Wed, 2006-11-15 at 22:27 +0530, Udayan Singh wrote:
>
> > 1. if i understood correctly.. The discussion thread : "wireless notes
> > / pre d80211 merge" discussion applies to the directory "net/d80211/"
> > from git:......
>
> Right. I CCed you because you seemed interested in d80211.
>

Thanks.. Johannes.. :)

> > 2. Test environment to setup for d80211 would be like this :
> >
> > Laptop (Centrino - with ipw2200 or would it be some other) <----> PC
> > acting as Access Point (with Wireless modem)
>
> no, ipw2200 doesn't do d80211. check drivers/net/wireless/d80211/
>

ok. you are referring to bcm43xx , etc

> > Any other that you would suggest that would be a more reasonable test
> > environment setup ?
> >
> > Also if you have suggestions which company of appliances i should go for..
>
> What do you want a test environment for? That's the key issue. I have a
> bunch of wireless hardware and an access point...
>

lets say we have development happening in d80211 driver. now if i want
to participate in the development of the (d80211), i can do it in a
much better manner if i am trying out modificaitons on my own on the
drivers that are using d80211 (my feeling) e.g. bcm43xx, etc. Hence i
would like to setup a test environment where i can make modifications
in code (of d80211 or related driver) and test it....

> > Few points that for clarification.
> > 1. I intend to do the same so that I can also check if I make any
> > changes how are they reflected. I hope my purpose would be solved with
> > above setup.
>
> Not sure what you mean? Do "the same" what?
>
same - "participate in development on d80211"

> > 2. How frequently would there be changes required in h/w here ?
>
> Umm, never?
>
> You fail to state what you actually want to do...
>

sorry for that, will surely try to give a complete picture in future
(tried that today again - hope its ok..).


> johannes
>
>
>

thanks..

Udayan
Tata Consultancy Services
