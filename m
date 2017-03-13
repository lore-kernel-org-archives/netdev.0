From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [RESEND PATCH -net] cpsw/netcp: cpts depends on posix_timers
Date: Mon, 13 Mar 2017 16:51:48 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1703131648350.14436@knanqh.ubzr>
References: <20170313165849.1378558-1-arnd@arndb.de> <alpine.LFD.2.20.1703131608100.14436@knanqh.ubzr> <CAK8P3a125rioB5Cnoa7nR9Dz_pU5=x7=06_DvXEE-dTpOBiitQ@mail.gmail.com> <alpine.LFD.2.20.1703131629570.14436@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        John Stultz <john.stultz@linaro.org>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.20.1703131629570.14436@knanqh.ubzr>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 13 Mar 2017, Nicolas Pitre wrote:

> So unless I'm mistaken I don't see any problem using "depends on 
> PTP_1588_CLOCK" here.

Furthermore that wouldn't be a first. See for example 
PTP_1588_CLOCK_GIANFAR, PTP_1588_CLOCK_IXP46X, DP83640_PHY, etc.


Nicolas
