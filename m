From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH][E1000E] some cleanups
Date: Tue, 09 Oct 2007 09:02:10 -0700
Message-ID: <470BA602.7060400@intel.com>
References: <1191174077.6165.11.camel@localhost>	 <47028351.7090509@intel.com>  <1191417498.4357.23.camel@localhost>	 <1191773723.4394.31.camel@localhost>  <470AB1EC.2080000@intel.com> <1191936581.4373.192.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18101 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753602AbXJIQCh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 12:02:37 -0400
In-Reply-To: <1191936581.4373.192.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2007-08-10 at 15:40 -0700, Kok, Auke wrote:
> 
>> My biggest problem with the patch as you sent it that it's a tonload of changes
>> and no implicit benefit immediately as I can see. 
> 
> The patch looks scary but is pretty tame when you apply it and stare at
> it.
> 
>> I would really have to see the
>> LLTX change as well to make a wellfounded decision whether it is the right thing
>> to go and overhaul this part of the driver or not :)
>>
>> I'm not particularly against the changes per se though.
>>
>> so please, if needed offlist send me those LLTX changes as well.
> 
> Dont worry about it - i didnt get any love for a similar patch i did for
> tg3 either ;-> I will hold onto it for now. I could do the un-LLTX
> outside of this - would you like that for both e1000/e1000e ?

if we're going to remove LLTX from e1000 I prefer to do that at a much later time.
Let's focus on e1000e instead - while it is still moving ;)

Auke
