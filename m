From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH 1/2] macb: Add 1588 support in Cadence GEM.
Date: Thu, 8 Sep 2016 09:44:44 +0200
Message-ID: <20160908074444.GA3341@netboy>
References: <1472820817-21874-1-git-send-email-andrei.pistirica@microchip.com>
 <20160906154809.GA7012@localhost.localdomain>
 <CAFcVECJxJgJUeO4=yudwTj5NkxDob5tCZaom9YTqWWmtt7ajFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrei Pistirica <andrei.pistirica@microchip.com>,
        netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>, davem@davemloft.net,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        Harini Katakam <harini.katakam@xilinx.com>,
        Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        Anirudha Sarangi <anirudh@xilinx.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        alexandre.belloni@free-electrons.com, tbultel@pixelsurmer.com
To: Harini Katakam <harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAFcVECJxJgJUeO4=yudwTj5NkxDob5tCZaom9YTqWWmtt7ajFw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 08, 2016 at 10:22:43AM +0530, Harini Katakam wrote:
> I cant be sure of the version of Cadence GEM used in SAMA5D2
> but these registers (sub ns increments alteast) only exist in
> the IP version used in Zynq Ultrascale+ MPSoC.

Then you need to find a way to make sure the driver only binds to the
correct silicon.

Thanks,
Richard
