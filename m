From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RFC V1 net-next 0/6] Time based packet transmission
Date: Tue, 19 Sep 2017 18:46:15 +0200
Message-ID: <20170919164615.mfv77pxuuyqc4zq4@localhost>
References: <cover.1505719061.git.rcochran@linutronix.de>
 <20170919144302.GB4347@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Cochran <rcochran@linutronix.de>, netdev@vger.kernel.org,
        Andre Guedes <andre.guedes@intel.com>,
        Henrik Austad <henrik@austad.us>, linux-kernel@vger.kernel.org,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        intel-wired-lan@lists.osuosl.org,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Anna-Maria Gleixner <anna-maria@linutronix.de>,
        David Miller <davem@davemloft.net>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170919144302.GB4347@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 19, 2017 at 04:43:02PM +0200, Miroslav Lichvar wrote:
> If I understand it correctly, this also allows us to make a PTP/NTP
> "one-step" clock with HW that doesn't support it directly.

Cool, yeah, I hadn't thought of that, but it would work...

Thanks,
Richard
