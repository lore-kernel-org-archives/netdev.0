From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tg3: Add the ability to conditionally build
 w/ HWMON
Date: Thu, 09 Mar 2017 13:04:09 -0800 (PST)
Message-ID: <20170309.130409.1461980220780640629.davem@davemloft.net>
References: <20170306205605.6547-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, siva.kallam@broadcom.com,
        prashant@broadcom.com, mchan@broadcom.com, aduyck@mirantis.com,
        tglx@linutronix.de, nicolas.pitre@linaro.org,
        jon.mason@broadcom.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170306205605.6547-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon,  6 Mar 2017 12:56:02 -0800

> Introduce a Kconfig option: CONFIG_TIGON3_HWMON which allows to build
> in/out support for thermal sensors reported by Tigon3 NICs.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
