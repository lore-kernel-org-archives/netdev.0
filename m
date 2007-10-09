From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][E1000E] some cleanups
Date: Tue, 09 Oct 2007 09:29:41 -0400
Message-ID: <1191936581.4373.192.camel@localhost>
References: <1191174077.6165.11.camel@localhost>
	 <47028351.7090509@intel.com>  <1191417498.4357.23.camel@localhost>
	 <1191773723.4394.31.camel@localhost>  <470AB1EC.2080000@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.182]:43668 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816AbXJIN3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 09:29:46 -0400
Received: by el-out-1112.google.com with SMTP id v27so304634ele
        for <netdev@vger.kernel.org>; Tue, 09 Oct 2007 06:29:45 -0700 (PDT)
In-Reply-To: <470AB1EC.2080000@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-08-10 at 15:40 -0700, Kok, Auke wrote:

> 
> My biggest problem with the patch as you sent it that it's a tonload of changes
> and no implicit benefit immediately as I can see. 

The patch looks scary but is pretty tame when you apply it and stare at
it.

> I would really have to see the
> LLTX change as well to make a wellfounded decision whether it is the right thing
> to go and overhaul this part of the driver or not :)
> 
> I'm not particularly against the changes per se though.
> 
> so please, if needed offlist send me those LLTX changes as well.

Dont worry about it - i didnt get any love for a similar patch i did for
tg3 either ;-> I will hold onto it for now. I could do the un-LLTX
outside of this - would you like that for both e1000/e1000e ?

cheers,
jamal

