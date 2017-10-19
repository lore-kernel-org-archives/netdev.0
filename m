From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RFC V1 net-next 0/6] Time based packet transmission
Date: Thu, 19 Oct 2017 13:44:09 -0700
Message-ID: <20171019204409.vmkhii2vocum43l6@localhost>
References: <cover.1505719061.git.rcochran@linutronix.de>
 <743a4550-7344-5e73-bf6d-6ec368263ad9@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Cochran <rcochran@linutronix.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        Andre Guedes <andre.guedes@intel.com>,
        Anna-Maria Gleixner <anna-maria@linutronix.de>,
        David Miller <davem@davemloft.net>,
        Henrik Austad <henrik@austad.us>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        "Briano, Ivan" <ivan.briano@intel.com>,
        Levi Pearson <levipearson@gmail.com>
To: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <743a4550-7344-5e73-bf6d-6ec368263ad9@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 18, 2017 at 03:18:55PM -0700, Jesus Sanchez-Palencia wrote:
> This is great. Just out of curiosity, were you using vlans on your tests?

No, just raw packets.  VLAN tags could be added trivially (in the
program), but that naturally avoids the kernel's VLAN code.

> I might try to reproduce them soon. I would appreciate if you could provide me
> with the scripts, please.

Ok, will do.

Thanks,
Richard
