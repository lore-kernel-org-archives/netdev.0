From: Francesco Piccinno <stack.box@gmail.com>
Subject: Re: [Bugme-new] [Bug 42132] New: Support BCM5750M in tg3
Date: Fri, 2 Sep 2011 02:02:13 +0200
Message-ID: <CAA7bCn69YZqh_d5AdfCjxBMOvMUKCgQMGHQf-T-seGoguW7oVw@mail.gmail.com>
References: <bug-42132-10286@https.bugzilla.kernel.org/> <20110901164011.baa9a8b8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Matt Carlson <mcarlson@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org, Benjamin Li <benli@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:46803 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932636Ab1IBACy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 20:02:54 -0400
Received: by yxj19 with SMTP id 19so801575yxj.19
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2011 17:02:53 -0700 (PDT)
In-Reply-To: <20110901164011.baa9a8b8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I know but apparently my laptop was lucky enough :)

Any chance to have the support for this card back?

On Fri, Sep 2, 2011 at 1:40 AM, Andrew Morton <akpm@linux-foundation.or=
g> wrote:
>
> (switched to email. =C2=A0Please respond via emailed reply-to-all, no=
t via the
> bugzilla web interface).
>
> On Wed, 31 Aug 2011 18:18:40 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D42132
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Summary: Support BCM5750M i=
n tg3
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Product: Drivers
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Version: 2.5
>> =C2=A0 =C2=A0 Kernel Version: 3.0.3
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Platform: All
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 OS/Version: Linux
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Tree: Mainline
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Status: NEW
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Severity: normal
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Priority: P1
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Component: Network
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 AssignedTo: drivers_network@kernel-bugs.=
osdl.org
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 ReportedBy: stack.box@gmail.com
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Regression: Yes
>>
>>
>> I have a notebook (HP TC4400) which has a BCM5750 ethernet card insi=
de. The
>> ouput of lspci is:
>>
>> 08:00.0 Ethernet controller [0200]: Broadcom Corporation NetXtreme B=
CM5750M
>> Gigabit Ethernet [14e4:167c]
>>
>> Commit 67b284d476bcb3d100e946da23d6cf9acfd0465c removed the support =
for this
>> device.
>>
>
> 67b284d476bcb3d100 says "These devices were never released to the pub=
lic".
>
>> I wish to have the support for this network card back again. Thanks!
>
> oops ;)
>
