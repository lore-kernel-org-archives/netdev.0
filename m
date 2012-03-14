From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next/usb-next v3 0/5] cdc-wdm/qmi_wwan: subdriver support
Date: Wed, 14 Mar 2012 13:51:51 +0100
Message-ID: <87obrzjqfs.fsf@nemi.mork.no>
References: <1330528507-16551-1-git-send-email-bjorn@mork.no>
	<878vjeuebk.fsf@nemi.mork.no> <4F608D56.9070704@phoenixhaven.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org,
	Dan Williams <dcbw@redhat.com>,
	Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org
To: "Nin Lil'izi" <nin-lil-izi@cf-protected.phoenixhaven.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43595 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760916Ab2CNMxa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 08:53:30 -0400
In-Reply-To: <4F608D56.9070704@phoenixhaven.net> (Nin Lil'izi's message of
	"Wed, 14 Mar 2012 12:21:42 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Nin Lil'izi" <nin-lil-izi@cf-protected.phoenixhaven.net> writes:

> Please forgive me for spamming this list.
> But is this module going to make it into the 3.3.0 final release?
>
> I've been testing it on my laptop while travelling on trains and thin=
gs
> using recent git pulls. And it releaves so much frustration vs the
> option module.
> As in spotty signal areas it drops in and out seamlessly without havi=
ng
> to manually reconnect everytime the train passes through a deadspot. =
And
> generally the connection is noticiably more stable in this use case :=
D
>
> Anyway I'd like to try it on my home connection which is run off an a=
tom
> device in a radio blackspot from hell. Which results in stuff having =
to
> be reconnected very often, even with huge external antenna attached. =
So
> this is like a dream come true in frustration saving but it takes
> 12hours to build a kernel. And cross compilation is labour intensive
> when you don't have the toolchain setup first. So am waiting for this=
 to
> hit a stable release before building it on that machine to save my sa=
nity.

Thanks for the nice feedback. =20

This was submitted far too late for it to be considered 3.3 material.
Not much to do about that.  Most of the developement happened after
3.3-rc1 anyway.  So I'm afraid you'll have to wait a couple months more
for the 3.4 release.

I understand that wasn't the message you wanted, but it does give us al=
l
a chance to test it thoroughly on different types of hardware. And mayb=
e
even prepare some userspace tools :-)

Which brings me to a couple of questions I have for you: What radio
hardware do you use (lsusb -v), and which userspace tools?

But we should maybe continue any userspace tool discussion here instead=
,
where it's a bit more on topic:
http://lists.freedesktop.org/mailman/listinfo/libqmi-devel


Bj=C3=B8rn
