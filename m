From: Jack Byer <ftn768@gmail.com>
Subject: Re: atl1e error messages in syslog
Date: Sun, 28 Nov 2010 21:15:47 -0600
Message-ID: <AANLkTikNVTtFWv9bMBqjtPPU7+a5VeopKNe+vaYbwFuE@mail.gmail.com>
References: <AANLkTikKb-B5RpMY0S3gbWrJ0FmzJqKmnQ1SiE+fXTZS@mail.gmail.com>
	<0FBC7C9C2640634A8B837C2EFFCFF32F01020383D1@SHEXMB-01.global.atheros.com>
	<AANLkTikQ0MDV76shwu5hVy-U4qF_ryHpx+JVV46Ly24+@mail.gmail.com>
	<0FBC7C9C2640634A8B837C2EFFCFF32F01020383D3@SHEXMB-01.global.atheros.com>
	<AANLkTik8gh8=wBCoTELchFAQih-+_b7sUJ4p2z1ojSeh@mail.gmail.com>
	<CDAFEDABF718A54BABD0DA54766953070141EF3233@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Xiong Huang <Xiong.Huang@atheros.com>,
	"jcliburn@gmail.com" <jcliburn@gmail.com>,
	"chris.snook@gmail.com" <chris.snook@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cloud Ren <Cloud.Ren@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:49387 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077Ab0K2DPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 22:15:49 -0500
Received: by qyk12 with SMTP id 12so5760185qyk.19
        for <netdev@vger.kernel.org>; Sun, 28 Nov 2010 19:15:47 -0800 (PST)
In-Reply-To: <CDAFEDABF718A54BABD0DA54766953070141EF3233@SHEXMB-01.global.atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 28, 2010 at 9:05 PM, Cloud Ren <Cloud.Ren@atheros.com> wrote:
> Hi,
>
> Can you give us driver version information?
>
> You can use " ethtool -i eth0" get it. thanks
>
This is the driver from kernel 2.6.38.1

driver: ATL1E
version: 1.0.0.7-NAPI
firmware-version: L1e
bus-info: 0000:02:00.0
