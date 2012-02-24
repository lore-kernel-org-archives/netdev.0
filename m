From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] davinci_mdio: Correct bitmask for clock divider value
Date: Fri, 24 Feb 2012 03:24:27 -0500
Message-ID: <20120224.032427.261928925990890713.davem@davemloft.net>
References: <1329984478-24090-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1329984478-24090-1-git-send-email-christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Date: Thu, 23 Feb 2012 09:07:58 +0100

> The CLKDIV bitfield in the MDIO Control Register is a 16 bit field,
> therefore the CLKDIV value may range from 0 to 0xffff.
> 
> Signed-off-by: Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>

Also applied to net-next.
