From: jamal <hadi@cyberus.ca>
Subject: Re: [Bugme-new] [Bug 15682] New: XFRM is not updating RTAX_ADVMSS
 metric
Date: Wed, 07 Apr 2010 08:19:11 -0400
Message-ID: <1270642751.7198.17.camel@bigi>
References: <bug-15682-10286@https.bugzilla.kernel.org/>
	 <20100405125055.cdc1e279.akpm@linux-foundation.org>
	 <1270561240.7198.3.camel@bigi>
	 <y2jb7b22e81004061202uac6ef8eeodc70d6deb65f7699@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	hideaki@yoshifuji.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eduardo Panisset <eduardo.panisset@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f193.google.com ([209.85.222.193]:47239 "EHLO
	mail-pz0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216Ab0DGMTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 08:19:22 -0400
Received: by pzk31 with SMTP id 31so958666pzk.33
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 05:19:21 -0700 (PDT)
In-Reply-To: <y2jb7b22e81004061202uac6ef8eeodc70d6deb65f7699@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eduardo,

As a first step, I dont know what the real cause is but 
what you showed as a solution didnt look right. I am also not familiar
with DSMIPv6. I know a lot of other xfrm subsystems work fine with
the current code. So thats why i pointed to Herbert who is more
knowledgeable. I am adding Yoshfuji to the list. 
If you tell me what kernel options to turn on and a very
basic test setup to reproduce it (I dont have much hardware, so make it
very minimal maybe requiring one or two PCs max) then I could make time
and try to reproduce it.

cheers,
jamal

On Tue, 2010-04-06 at 16:02 -0300, Eduardo Panisset wrote:
> Hi,
> 
> My intention is only to report a problem that I have faced. The
> solution proposed isn't (I know that) probably the best one to adopt
> as I'm not a kernel specialist, it is more illustrative to allow you
> guys understanding what I'm meaning and solve that on the better way
> (hence I haven't submited a patch).
> 
> Regards,
> Eduardo Panisset.

