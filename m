From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] core: Simplify logic in dev_load().
Date: Wed, 3 Sep 2014 09:04:55 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1748631F@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D174856D6@AcuExch.aculab.com>
 <5406033C.40507@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Sergei Shtylyov' <sergei.shtylyov@cogentembedded.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43641 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751573AbaICJGF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 05:06:05 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17418-03 for <netdev@vger.kernel.org>;
 Wed,  3 Sep 2014 10:05:55 +0100 (BST)
In-Reply-To: <5406033C.40507@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > The code in dev_load() is convoluted.
> > Return early and remove the 'no_module' variable.
> 
>     You forgot to sign off on the patch, so it can't be applied.

Gah, git defaults and brain-fade.

Does that mean that if I submit a patch without a sign-off then no one
else is allowed to submit the same patch?
I see a DoS attack :-)

	David
