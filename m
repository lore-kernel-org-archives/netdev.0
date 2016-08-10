From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [RFC PATCH 2/3] net: macb: Add support for 1588 for Zynq
 Ultrascale+ MPSoC
Date: Wed, 10 Aug 2016 15:52:20 +0530
Message-ID: <CAFcVEC+qmgZ55BsDwCKSLQo0FcYT6zSUz8L7ULC7dTw6uB+fOQ@mail.gmail.com>
References: <1441958258-35441-1-git-send-email-harinik@xilinx.com>
 <1441958258-35441-3-git-send-email-harinik@xilinx.com> <CAFcVECLfXL-=efbUhNeKhiFQgtfv6Z1+JJckg+js7DM-LfFeSw@mail.gmail.com>
 <99d6c0ce-c3b9-a919-cedb-0af954bac388@atmel.com> <03CA77BA8AF6F1469AEDFBDA1322A7B74A1C4205@XAP-PVEXMBX02.xlnx.xilinx.com>
 <b680d509-5a30-1960-8aea-485befc2d57b@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Boris Brezillon <boris.brezillon@free-electrons.com>,
	"alexandre.belloni@free-electrons.com"
	<alexandre.belloni@free-electrons.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Michal Simek <michals@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>
To: Andrei Pistirica <andrei.pistirica@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37009 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933335AbcHJT0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 15:26:08 -0400
In-Reply-To: <b680d509-5a30-1960-8aea-485befc2d57b@microchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrei,

On Wed, Aug 10, 2016 at 3:42 PM, Andrei Pistirica
<andrei.pistirica@microchip.com> wrote:
> Hi Punnaiah,
>
> cpts_match(...) has a way to parse frames, while ptp_classify_raw identifies
> the underlying protocol (in case the frames are parsed on data path), or
> tx/rxtstamp callbacks can be used with PTP events. But, there is comment in
> ptp_classify.h which worries me.
>
> Unfortunately,  I cannot access https://gitenterprise.xilinx.com.

Please access this public repo:
https://github.com/Xilinx/linux-xlnx

Regards,
Harini
