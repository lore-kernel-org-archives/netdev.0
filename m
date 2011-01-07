From: Janne Karhunen <janne.karhunen@gmail.com>
Subject: Re: via-velocity: corrupted mac, deadlock on link
Date: Fri, 7 Jan 2011 17:31:07 +0200
Message-ID: <AANLkTikFik4t8Vu8CkUWCCR5yZ4cpVdEdP9qPHT3DQBQ@mail.gmail.com>
References: <AANLkTi=SV=_s3ViveEX4e2FpEGKK+w6BiGs=QYCsgPsv@mail.gmail.com>
	<20110106125822.70a85e0a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:63070 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748Ab1AGPbI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 10:31:08 -0500
Received: by pxi15 with SMTP id 15so3080883pxi.19
        for <netdev@vger.kernel.org>; Fri, 07 Jan 2011 07:31:07 -0800 (PST)
In-Reply-To: <20110106125822.70a85e0a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 6, 2011 at 10:58 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:

> To debug, remove the udev rule that does renaming
> =A0cd /lib/udev
> =A0mkdir save; mv rules.d/75-persistent-net-generator-rules save
> and remove any rules
> =A0rm /etc/udev/70-persistent-net.rules
>
> Then after bootup you can debug problem.

Yeah.. before wasting anyones time with this, will have the
board replaced just in case. Looks suspicious enough already.
Thanks.


--=20
// Janne
