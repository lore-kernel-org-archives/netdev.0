From: Andre Heider <a.heider@gmail.com>
Subject: Re: [PATCH 0/3] ps3_gelic: Fix error paths when a tx dma fails
Date: Thu, 14 Jul 2011 10:36:32 +0200
Message-ID: <CAHsu+b89+SN8RE4Ce-evC97pw8bgZgjnOW_+z6NDXu6bGuRO+w@mail.gmail.com>
References: <1310501606-829-1-git-send-email-a.heider@gmail.com>
	<4E1E1CDE.2060504@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, cbe-oss-dev@lists.ozlabs.org
To: Geoff Levand <geoff@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:56525 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903Ab1GNIge convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 04:36:34 -0400
Received: by eyx24 with SMTP id 24so15406eyx.19
        for <netdev@vger.kernel.org>; Thu, 14 Jul 2011 01:36:32 -0700 (PDT)
In-Reply-To: <4E1E1CDE.2060504@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Geoff,

On Thu, Jul 14, 2011 at 12:31 AM, Geoff Levand <geoff@infradead.org> wr=
ote:
> Hi Andre,
>
> On 07/12/2011 01:13 PM, Andre Heider wrote:
>> This series fixes a few bugs for the error paths once a tx dma reque=
st
>> fails. Without these I either ran into BUG_ON, the device got killed=
,
>> or the kernel crashed.
>
> Thanks for preparing the fixes. =A0I added them to my ps3-linux
> tree and did some quick tests which didn't show any problems.
> I'll try to do some more through testing with them sometime
> soon.

nice, thanks :)

Regards,
Andre
