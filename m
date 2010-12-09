From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: [Bugme-new] [Bug 24472] New: Kernel panic - not syncing: Fatal
 Exception
Date: Thu, 09 Dec 2010 13:40:19 +0100
Message-ID: <4D00CE33.8040006@itcare.pl>
References: <bug-24472-10286@https.bugzilla.kernel.org/> <20101208122233.835a4997.akpm@linux-foundation.org> <4CFFEB01.7040700@itcare.pl> <4D000045.3040102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pstaszewski@artcom.pl
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:37968 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754944Ab0LIMkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 07:40:08 -0500
In-Reply-To: <4D000045.3040102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2010-12-08 23:01, Jarek Poplawski pisze:
> Pawe=C5=82 Staszewski wrote:
>> W dniu 2010-12-08 21:22, Andrew Morton pisze:
>>> (switched to email.  Please respond via emailed reply-to-all, not v=
ia the
>>> bugzilla web interface).
>>>
>>> On Wed, 8 Dec 2010 20:14:45 GMT
>>> bugzilla-daemon@bugzilla.kernel.org wrote:
>>>
>>>> https://bugzilla.kernel.org/show_bug.cgi?id=3D24472
>>>>
>>>>              Summary: Kernel panic - not syncing: Fatal Exception
>>>>              Product: Drivers
>>>>              Version: 2.5
>>>>       Kernel Version: 2.6.36.1
> Hi,
> Could you try to revert this patch?:
> http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.36.y.git=
;a=3Dcommitdiff;h=3D55c95e738da85373965cb03b4f975d0fd559865b
>
After reverting this patch all is working
200 connects-disconnects and no kernel panic

I will make more session and test more.


Thanks
Pawel
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

