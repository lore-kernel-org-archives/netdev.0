From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6] 2.6.0-test11 - more rtl8169
Date: Sun, 07 Dec 2003 13:14:23 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FD36DFF.4060503@pobox.com>
References: <1070212415.1607.17.camel@oxygenium> <20031201020453.A16405@electric-eye.fr.zoreil.com> <20031202010649.A27879@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com,
        =?ISO-8859-1?Q?Fernando_Alencar_Mar=F3stica?=
 <famarost@unimep.br>,
        Brad House <brad@mcve.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20031202010649.A27879@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Get:
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.0-test11-netdrv/r8169-blob.tar.bz2 
> Same thing as above with:
> r8169-mac-phy-version.patch
> r8169-init_one.patch
> r8169-timer.patch
> r8169-hw_start.patch
> r8169-missing-tx-stats.patch
> r8169-intr_mask.patch
> r8169-suspend.patch
> r8169-dma-api-rx-buffers-ahum.patch


All the above patches applied, in the above order.

Thanks much, Francois!

Is there anything left?

	Jeff


P.S.  Will release updated 2.5-exp patch soon.
