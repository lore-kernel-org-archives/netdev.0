From: Jack Byer <ftn768@gmail.com>
Subject: Re: atl1e error messages in syslog
Date: Sun, 28 Nov 2010 18:29:36 -0600
Message-ID: <AANLkTikQ0MDV76shwu5hVy-U4qF_ryHpx+JVV46Ly24+@mail.gmail.com>
References: <AANLkTikKb-B5RpMY0S3gbWrJ0FmzJqKmnQ1SiE+fXTZS@mail.gmail.com>
	<0FBC7C9C2640634A8B837C2EFFCFF32F01020383D1@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "jcliburn@gmail.com" <jcliburn@gmail.com>,
	"chris.snook@gmail.com" <chris.snook@gmail.com>,
	Cloud Ren <Cloud.Ren@atheros.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Xiong Huang <Xiong.Huang@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:49076 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754176Ab0K2A3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 19:29:37 -0500
Received: by qwb7 with SMTP id 7so3879410qwb.19
        for <netdev@vger.kernel.org>; Sun, 28 Nov 2010 16:29:36 -0800 (PST)
In-Reply-To: <0FBC7C9C2640634A8B837C2EFFCFF32F01020383D1@SHEXMB-01.global.atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 28, 2010 at 6:26 PM, Xiong Huang <Xiong.Huang@atheros.com> wrote:
> It's abnormal. Could you tell us the driver version & pci device ID?
>
I am using kernel version 2.6.36.1


02:00.0 Ethernet controller: Attansic Technology Corp. Atheros
AR8121/AR8113/AR8114 PCI-E Ethernet Controller (rev b0)
        Subsystem: ASUSTeK Computer Inc. Device 831c
        Flags: bus master, fast devsel, latency 0, IRQ 42
        Memory at fe9c0000 (64-bit, non-prefetchable) [size=256K]
        I/O ports at dc00 [size=128]
        Capabilities: [40] Power Management version 2
        Capabilities: [48] MSI: Enable+ Count=1/1 Maskable- 64bit+
        Capabilities: [58] Express Endpoint, MSI 00
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [180] Device Serial Number ff-69-3b-5c-90-e6-ba-ff
        Kernel driver in use: ATL1E
        Kernel modules: atl1e
