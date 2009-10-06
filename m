From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH] iproute2 add hoplimit and reordering route options usage
 and parsing
Date: Tue, 06 Oct 2009 14:37:06 +0200
Message-ID: <4ACB39F2.6080002@codefidence.com>
References: <1254732861.015524.19779.nullmailer@watson.codefidence.com> <20091006114142.GA11012@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ori@comsleep.com
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:32923 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932431AbZJFMhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 08:37:41 -0400
In-Reply-To: <20091006114142.GA11012@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Henriksson wrote:

> Hello!
>
> On Mon, Oct 05, 2009 at 10:54:21AM +0200, Gilad Ben-Yossef wrote:
>   
>> iproute2 git HEAD (spotted originally on 2.6.26, so it's probably not new) 
>> does  not parse the hoplimit route option when proccessing parameters, nor 
>> does it  print hoplimit and reordering options in the usage lines.  
>>     
>
> I'm happy you brought this up and know the author. The Debian package
> has been carrying this code, which is now in the form of a patch available
> here:
> http://git.debian.org/?p=collab-maint/pkg-iproute.git;a=blob;f=debian/patches/hoplimit.dpatch
>
> I didn't know who the original author was which is why I haven't submitted it,
> but it seems you know the history....
>   
Not exactly. I know the history of the patch *I sent* (and btw, it seems 
I got the author name wrong). I don't think it is related to the one 
Debian is carrying.
> The above patch also includes some minor documentation updates which you seem
> to be missing and might want to integrate in your version of the patch.
>   
All right. I will add those documentation changes as well and resend as 
version 2.
> Looking forward to be able to drop the patch in the debian package!
>
>
>
>   
I take it you ACK the patch as the Debian package maintainer?

Thanks!
Gilad


-- 
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
Fax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxology.net

	"Now the world has gone to bed
	 Darkness won't engulf my head
	 I can see by infra-red
	 How I hate the night."

