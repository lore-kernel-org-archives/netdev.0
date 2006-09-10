From: Gnome42 <gnome42@gmail.com>
Subject: Re: IPSec broken in 2.6.18-rc4-mm3
Date: Sat, 9 Sep 2006 21:09:45 -0400
Message-ID: <fa4052ef0609091809s87574a7n2f9e20312a795fc9@mail.gmail.com>
References: <fa4052ef0609080926j5bbae070mccb9699f0e5eb1fb@mail.gmail.com>
	 <4501CA01.3050904@trash.net>
	 <fa4052ef0609081332l3c4d25a3xe5e315482884e1a8@mail.gmail.com>
	 <4502C81E.600@trash.net>
	 <fa4052ef0609090735o6e17da23y75bd6f742a8a29be@mail.gmail.com>
	 <4502EA5C.5020101@trash.net>
	 <fa4052ef0609091039t65205ed3te10b5db571d20706@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:10055 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S965069AbWIJBJq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Sep 2006 21:09:46 -0400
Received: by py-out-1112.google.com with SMTP id n25so1509396pyg
        for <netdev@vger.kernel.org>; Sat, 09 Sep 2006 18:09:46 -0700 (PDT)
To: "Patrick McHardy" <kaber@trash.net>
In-Reply-To: <fa4052ef0609091039t65205ed3te10b5db571d20706@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

It is working in 2.6.18-rc6-mm1. I thought it was the compile option
'optimize for size' that was causing a miscompilation because when I
compiled -rc6-mm1 I turned that option off and it suddenly started
working. But, then I recompiled -rc5-mm1 with that option off and it
still didn't work. So, it must have been fixed in -mm1 itself I guess.

Thanks for your time & help,

Shane
