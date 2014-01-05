From: Asi Lichtenstein <asili22@gmail.com>
Subject: Re: How to add IPv6 multiple routing tables support to 2.6.16.26 kernel
Date: Sun, 5 Jan 2014 15:49:34 +0200
Message-ID: <CAMBtn_3jpNh=gvxkzVzSqgj3OEXYyqUdPb7Y63Jm-PVhx7U=DA@mail.gmail.com>
References: <CAMBtn_3=6-W0VG2oxBt6SUJ6ead0ao4oV49K8w4oSNNGu190mw@mail.gmail.com>
	<1388928328.15823.YahooMailBasic@web125504.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Fran=E7ois=2DXavier_Le_Bail?= <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:47743 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbaAENtf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 08:49:35 -0500
Received: by mail-oa0-f52.google.com with SMTP id o6so1132715oag.39
        for <netdev@vger.kernel.org>; Sun, 05 Jan 2014 05:49:34 -0800 (PST)
In-Reply-To: <1388928328.15823.YahooMailBasic@web125504.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It does look promising, are there any other related patches?
I need such support with netlink to be able to use netlink to
configure the kernel.

10x

On Sun, Jan 5, 2014 at 3:25 PM, Fran=E7ois-Xavier Le Bail
<fx.lebail@yahoo.com> wrote:
> Hello,
>
> Are you looking for this ?
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/patch/=
?id=3Dc71099acce933455123ee505cc75964610a209ad
>
> BR
>
> --------------------------------------------
> On Sun, 1/5/14, Asi Lichtenstein <asili22@gmail.com> wrote:
>
>  Subject: Re: How to add IPv6 multiple routing tables support to 2.6.=
16.26 kernel
>  To: "netdev" <netdev@vger.kernel.org>
>  Date: Sunday, January 5, 2014, 6:33 AM
>
>  I know that this kernel is way too
>  long but this is something that I
>  can't change.
>  It is not up to me to decide on kernel upgrade.
>
>  I was talking about IPv6 multiple route tables.
>  This is something that was added later in:
>  http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commi=
t/?id=3Dc71099acce933455123ee505cc75964610a209ad
>  I've posted this thread to help me finding this patch:
>  http://thread.gmane.org/gmane.linux.network/41149
>
>
