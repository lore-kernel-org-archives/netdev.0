From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH v3] net: ethernet: support "fixed-link" DT node on nb8800
 driver
Date: Mon, 08 Feb 2016 15:38:37 +0100
Message-ID: <56B8A86D.7060403@laposte.net>
References: <56B4A445.7080402@laposte.net> <yw1x1t8ri8dz.fsf@unicorn.mansr.com> <56B4A877.4020800@laposte.net> <yw1xsi17gsxl.fsf@unicorn.mansr.com> <56B4ACC4.1000607@laposte.net> <yw1xoabvgs7s.fsf@unicorn.mansr.com> <56B4B013.5030407@laposte.net> <yw1xk2mjgraf.fsf@unicorn.mansr.com> <56B4B81D.3000108@laposte.net> <yw1xfux7gpol.fsf@unicorn.mansr.com> <56B4BDDA.9010708@laposte.net> <yw1xbn7vgoux.fsf@unicorn.mansr.com> <56B86F44.3030806@laposte.net> <yw1xfux3fhmq.fsf@unicorn.mansr.com> <56B8A21C.5020400@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Mason <slash.tmp@free.fr>, Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz29.laposte.net ([194.117.213.104]:57740 "EHLO
	smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753242AbcBHOil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 09:38:41 -0500
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout017 (Postfix) with ESMTP id 0DB65A00BF4
	for <netdev@vger.kernel.org>; Mon,  8 Feb 2016 15:38:39 +0100 (CET)
Received: from lpn-prd-vrin004 (lpn-prd-vrin004.laposte [10.128.63.5])
	by lpn-prd-vrout017 (Postfix) with ESMTP id 0038AA00C13
	for <netdev@vger.kernel.org>; Mon,  8 Feb 2016 15:38:38 +0100 (CET)
Received: from lpn-prd-vrin004 (localhost [127.0.0.1])
	by lpn-prd-vrin004 (Postfix) with ESMTP id DFF1070E267
	for <netdev@vger.kernel.org>; Mon,  8 Feb 2016 15:38:38 +0100 (CET)
In-Reply-To: <56B8A21C.5020400@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2016 03:11 PM, Mason wrote:
> On 08/02/2016 14:37, M=E5ns Rullg=E5rd wrote:
>
>> Sebastian Frias wrote:
>>
>>> By the way, I know some people like the command line, email, etc. b=
ut
>>> there ought to be other tools better suited for patch review...
>>
>> Some kernel subsystems use http://patchwork.ozlabs.org/ to track sta=
tus
>> of various patches.
>
> There's also a kernel bugzilla, but it may be for actual bugs.
> https://bugzilla.kernel.org/
>

Thanks, and what would be the definition of a bug?
I mean, would the issue from this thread qualify?
Should I have created a bug report before submitting the patch?
