From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPSec broken in 2.6.18-rc4-mm3
Date: Sun, 10 Sep 2006 03:12:06 +0200
Message-ID: <45036666.1090704@trash.net>
References: <fa4052ef0609080926j5bbae070mccb9699f0e5eb1fb@mail.gmail.com>	 <4501CA01.3050904@trash.net>	 <fa4052ef0609081332l3c4d25a3xe5e315482884e1a8@mail.gmail.com>	 <4502C81E.600@trash.net>	 <fa4052ef0609090735o6e17da23y75bd6f742a8a29be@mail.gmail.com>	 <4502EA5C.5020101@trash.net>	 <fa4052ef0609091039t65205ed3te10b5db571d20706@mail.gmail.com> <fa4052ef0609091809s87574a7n2f9e20312a795fc9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58877 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965072AbWIJBPA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Sep 2006 21:15:00 -0400
To: Gnome42 <gnome42@gmail.com>
In-Reply-To: <fa4052ef0609091809s87574a7n2f9e20312a795fc9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gnome42 wrote:
> It is working in 2.6.18-rc6-mm1. I thought it was the compile option
> 'optimize for size' that was causing a miscompilation because when I
> compiled -rc6-mm1 I turned that option off and it suddenly started
> working. But, then I recompiled -rc5-mm1 with that option off and it
> still didn't work. So, it must have been fixed in -mm1 itself I guess.

Good, I coulnd't find anything (but discovered that the statistic didn't
count out of replay window packets but failed authenticity checks).

Thanks for the information.

