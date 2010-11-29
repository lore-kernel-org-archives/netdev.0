From: Xiong Huang <Xiong.Huang@Atheros.com>
Subject: RE: atl1e error messages in syslog
Date: Mon, 29 Nov 2010 08:32:36 +0800
Message-ID: <0FBC7C9C2640634A8B837C2EFFCFF32F01020383D3@SHEXMB-01.global.atheros.com>
References: <AANLkTikKb-B5RpMY0S3gbWrJ0FmzJqKmnQ1SiE+fXTZS@mail.gmail.com>
	<0FBC7C9C2640634A8B837C2EFFCFF32F01020383D1@SHEXMB-01.global.atheros.com>
 <AANLkTikQ0MDV76shwu5hVy-U4qF_ryHpx+JVV46Ly24+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jcliburn@gmail.com" <jcliburn@gmail.com>,
	"chris.snook@gmail.com" <chris.snook@gmail.com>,
	Cloud Ren <Cloud.Ren@Atheros.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jack Byer <ftn768@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shgateway.atheros.com ([203.110.175.210]:21005 "EHLO
	mail.atheros.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754334Ab0K2Acj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 19:32:39 -0500
In-Reply-To: <AANLkTikQ0MDV76shwu5hVy-U4qF_ryHpx+JVV46Ly24+@mail.gmail.com>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I can't recognize it unless you give me the PCI device ID.

BR.
Xong

-----Original Message-----
From: Jack Byer [mailto:ftn768@gmail.com] 
Sent: Monday, November 29, 2010 8:30 AM
To: Xiong Huang
Cc: jcliburn@gmail.com; chris.snook@gmail.com; Cloud Ren; netdev@vger.kernel.org
Subject: Re: atl1e error messages in syslog

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
