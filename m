From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Re: Another oops + repost
Date: Mon, 26 Jul 2010 05:21:45 +0200
Message-ID: <AANLkTimC8q6_ZU60VX5SmXGqsD+RCpf4RaF3MLQptsG4@mail.gmail.com>
References: <AANLkTin_KDKEejs1ld-qv5jOyuALysjZ8NLC2-786htJ@mail.gmail.com>
	<m1zkxjwjq9.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, 577640@bugs.debian.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:35021 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288Ab0GZDVr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jul 2010 23:21:47 -0400
Received: by eya25 with SMTP id 25so378894eya.19
        for <netdev@vger.kernel.org>; Sun, 25 Jul 2010 20:21:45 -0700 (PDT)
In-Reply-To: <m1zkxjwjq9.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Jul 22, 2010 at 18:43, Eric W. Biederman <ebiederm@xmission.com=
> wrote:

>> First of all, I would like to know if anybody was able to fix this
>> problem =A0that got kinda lost in the thread:
>
> I can't reproduce this on 2.6.35-rc1+
>
> Can you please test a 2.6.35-rc version? =A0If you can still reproduc=
e
> it there can you send me your .config? =A0Otherwise I expect my last
> round of changes to sysfs fixed whatever was the underlying problem.

I just download and compiled rc6, and all of these problems seem to be
solved. Thanks a lot!

--=20
Mart=EDn Ferrari
