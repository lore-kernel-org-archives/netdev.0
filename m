From: Leigh Brown <leigh@solinno.co.uk>
Subject: Re: [PATCH] net: mvmdio: fix interrupt timeout handling
Date: Thu, 19 Dec 2013 12:39:22 +0000
Message-ID: <a1205db8e38fbdc0cf64f235de54cc67@doppler.thel33t.co.uk>
References: <1387451589-15491-1-git-send-email-leigh@solinno.co.uk>
 <52B2D97F.4070200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Florian Fainelli <florian@openwrt.org>,
	linux-arm-kernel@lists.infradead.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52B2D97F.4070200@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013-12-19 11:33, Sebastian Hesselbarth wrote:
>> +			 if (timeout < 2)
>> +			 	timeout = 2;
> 
> Hi Leigh,
> 
> above two lines have a whitespace issue.

Crap, you are correct.  I will fix it and send another patch.

Regards,

Leigh.
