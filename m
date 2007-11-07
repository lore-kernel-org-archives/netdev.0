From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH 00/05] ipv6: RFC4214 Support
Date: Wed, 7 Nov 2007 16:41:51 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711071635160.10003@netcore.fi>
References: <OFF45233E5.73C392C8-ON8825738C.00298603-8825738C.002B4AB8@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, Fred.L.Templin@boeing.com,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:52669 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758388AbXKGO6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 09:58:08 -0500
In-Reply-To: <OFF45233E5.73C392C8-ON8825738C.00298603-8825738C.002B4AB8@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Nov 2007, David Stevens wrote:
>> give it away on this specific instance.  I'm not sure if you should
>> attribute to hidden agendas what you can explain by "doing the right
>> thing" (granted, very few companies do this which may make it suspect,
>> but still..).
>
> Pekka,
>        I'm not assuming hidden agendas here; I simply don't know what
> they mean by "no license for implementers."  It doesn't say they
> relinquish *all* licensing, which would be clearer if that's what they
> mean. If implementers, distributors, and users are included, then
> who's left that does need licensing? If that answer really is nobody,
> then why bother with "for implementers."?
>        So, I don't think it's a hidden agenda, I think they said what
> they mean. I just don't know what they mean. :-)

If you look at the page they used to file the disclosure:

https://datatracker.ietf.org/ipr/new-specific/

You'll notice that they chose the most relaxed option available, and 
all the options only discuss implementers not distributors.

Now, if you look at the background commentary of the subject:

http://tools.ietf.org/html/rfc3905

.. the comment about that particular option is:

    a) No License Required for Implementers: The Patent Holder does not
       require parties to acquire any license to its Necessary Patent
       Claims in order to make, have made, use, import, offer to sell,
       sell, or distribute technology that implements such an IETF
       specification.

Seems clear to me, though someone could argue whether RFC 3905 is 
normative in this context, i.e., whether the person who submitted the 
disclosure understood the comment quoted above and that that's the way 
"no license required for implementers" must be interpreted.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
