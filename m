From: Josh Boyer <jwboyer@gmail.com>
Subject: Re: Backtrace in rds code
Date: Tue, 24 Jan 2012 22:48:11 -0500
Message-ID: <CA+5PVA7gZDj9=_JK-7p=Ntz5SCnHXkZ+8uX5knBRjbB=PMOv6w@mail.gmail.com>
References: <CA+5PVA7jGq6Hu3ebCzG1FJJStEcsN251Q_0pS9PphkeuAPKxww@mail.gmail.com>
	<20120124.170410.829129930720684609.davem@davemloft.net>
	<CA+5PVA5QFUctweSVYp2OxGAvXOdoxaX6gcsKdKMW6WktyYX6QA@mail.gmail.com>
	<20120124.204925.1007060639610978158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: venkat.x.venkatsubra@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:47196 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375Ab2AYDsN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 22:48:13 -0500
Received: by wics10 with SMTP id s10so3473448wic.19
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 19:48:11 -0800 (PST)
In-Reply-To: <20120124.204925.1007060639610978158.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2012 at 8:49 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Josh Boyer <jwboyer@gmail.com>
> Date: Tue, 24 Jan 2012 19:26:25 -0500
>
>> Using the same base kernel as I did to report the issue, plus this p=
atch the
>> issue seems to be gone. =A0I can't really claim rds works overall, b=
ut the oops
>> output is definitely cleared up.
>>
>> Thanks for such a quick turn around.
>
> Thanks for testing, the fix is already in Linus's tree and I'll ship
> it off to -stable eventually too.

Great.  FWIW, I tested a 3.2.1+this patch build and it works there as w=
ell.

josh
