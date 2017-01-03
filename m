From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH net-next v4 1/2] macb: Add 1588 support in Cadence
 GEM.
Date: Tue, 3 Jan 2017 11:29:58 +0100
Message-ID: <20170103102958.GC24780@localhost.localdomain>
References: <1481720175-12703-1-git-send-email-andrei.pistirica@microchip.com>
 <BN3PR07MB2516815EDE69ACDCE27F81A3C96F0@BN3PR07MB2516.namprd07.prod.outlook.com>
 <20170102113155.GA16373@localhost.localdomain>
 <0717c63b-2e29-9ad1-7f01-39817980933f@atmel.com>
 <20170102161359.GD3609@localhost.localdomain>
 <CAFcVECK1vt7Hu4tgSZ2+kKpMxoT-wpikMDq65HaxRv-EMgobHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
        Rafal Ozieblo <rafalo@cadence.com>,
        Andrei Pistirica <andrei.pistirica@microchip.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "punnaia@xilinx.com" <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        "anirudh@xilinx.com" <anirudh@xilinx.com>,
        "boris.brezillon@free-electrons.com"
        <boris.brezillon@free-electrons.com>,
        "alexandre.belloni@free-electrons.com"
        <alexandre.belloni@free-electrons.com>,
        "tbultel@pixelsurmer.com" <tbultel@pixelsurmer.com>
To: Harini Katakam <harinikatakamlinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35420 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750992AbdACKaE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 05:30:04 -0500
Content-Disposition: inline
In-Reply-To: <CAFcVECK1vt7Hu4tgSZ2+kKpMxoT-wpikMDq65HaxRv-EMgobHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 03, 2017 at 10:36:11AM +0530, Harini Katakam wrote:
> I understand that it is not accurate - it is an initial version.

Why do you say, "it is an initial version?"

The Atmel device has this IP core burned in.  The core is hopelessly
broken, and it cannot be fixed in SW either, so what is your point?

Thanks,
Richard
