From: Nikola Pajkovsky <n.pajkovsky@gmail.com>
Subject: Re: [PATCH] b44: fix section mismatch warnings in b44.c
Date: Sun, 19 Feb 2012 21:28:02 +0100
Message-ID: <m5sji6zhyl.fsf@redhat.com>
References: <c8f624fdb13dcf32d82b1abb70a423abc4a2359a.1329662367.git.n.pajkovsky@gmail.com>
	<20120219201332.GF2855@mwanda>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Nikola Pajkovsky <n.pajkovsky@gmail.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:64989 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739Ab2BSU06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2012 15:26:58 -0500
In-Reply-To: <20120219201332.GF2855@mwanda> (Dan Carpenter's message of "Sun,
	19 Feb 2012 23:13:32 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter <dan.carpenter@oracle.com> writes:

> On Sun, Feb 19, 2012 at 03:45:54PM +0100, Nikola Pajkovsky wrote:
>> From: Nikola Pajkovsky <n.pajkovsky@gmail.com>
>> 
>
> This changelog is not really helpful.
>
> Why did you remove an __exit anotation instead changing the callers?
> Obviously I looked at the code, so I can answer that question, but I
> shouldn't have to.  It should be explained in the changelog.

I will rephrase comment

> Sometimes I add in information about when the error message was
> introduced.
>
> It might also be nice to mention what the bad effects of this
> problem are.
>
>> Signed-off-by: Nikola Pajkovsky <n.pajkovsky@gmail.com>
>                                    ^^^^^^^^^^^^^^^^^^^^^
> You're sending the patch from your redhat address; it's best to sign
> it with the redhat address as well.

oops, it should be from gmail

-- 
Nikola
