From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 24472] New: Kernel panic - not syncing: Fatal
 Exception
Date: Wed, 08 Dec 2010 23:01:41 +0100
Message-ID: <4D000045.3040102@gmail.com>
References: <bug-24472-10286@https.bugzilla.kernel.org/> <20101208122233.835a4997.akpm@linux-foundation.org> <4CFFEB01.7040700@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pstaszewski@artcom.pl
To: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53125 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985Ab0LHWBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 17:01:47 -0500
Received: by wyb28 with SMTP id 28so1573925wyb.19
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 14:01:46 -0800 (PST)
In-Reply-To: <4CFFEB01.7040700@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pawe=C5=82 Staszewski wrote:
> W dniu 2010-12-08 21:22, Andrew Morton pisze:
>> (switched to email.  Please respond via emailed reply-to-all, not vi=
a the
>> bugzilla web interface).
>>
>> On Wed, 8 Dec 2010 20:14:45 GMT
>> bugzilla-daemon@bugzilla.kernel.org wrote:
>>
>>> https://bugzilla.kernel.org/show_bug.cgi?id=3D24472
>>>
>>>             Summary: Kernel panic - not syncing: Fatal Exception
>>>             Product: Drivers
>>>             Version: 2.5
>>>      Kernel Version: 2.6.36.1

Hi,
Could you try to revert this patch?:
http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.36.y.git;a=
=3Dcommitdiff;h=3D55c95e738da85373965cb03b4f975d0fd559865b

Jarek P.
