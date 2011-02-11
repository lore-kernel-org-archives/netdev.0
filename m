From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH v2 09/13] can: pruss CAN driver.
Date: Fri, 11 Feb 2011 16:06:02 +0100
Message-ID: <20110211150602.GB373@e-circ.dyndns.org>
References: <1297435892-28278-1-git-send-email-subhasish@mistralsolutions.com>
	<1297435892-28278-10-git-send-email-subhasish@mistralsolutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	"open list:CAN NETWORK DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	nsekhar-l0cyMroinI0@public.gmane.org, open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:CAN NETWORK DRIVERS" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, m-watkins-l0cyMroinI0@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1297435892-28278-10-git-send-email-subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 11, 2011 at 08:21:28PM +0530, Subhasish Ghosh wrote:
> +config DA8XX_PRU_CANID_MBX0
> +	hex "CANID for mailbox 0"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	---help---
> +	Enter the CANID for mailbox 0
> +	Default value is set to 0x123, change this as required.
> +
> +config DA8XX_PRU_CANID_MBX1
> +	hex "CANID for mailbox 1"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	 ---help---
> +	Enter the CANID for mailbox 1
> +	Default value is set to 0x123, change this as required.
> +
> +config DA8XX_PRU_CANID_MBX2
> +	hex "CANID for mailbox 2"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	---help---
> +	Enter the CANID for mailbox 2
> +	Default value is set to 0x123, change this as required.
> +
> +config DA8XX_PRU_CANID_MBX3
> +	hex "CANID for mailbox 3"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	---help---
> +	Enter the CANID for mailbox 3
> +	Default value is set to 0x123, change this as required.
> +
> +config DA8XX_PRU_CANID_MBX4
> +	hex "CANID for mailbox 4"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	---help---
> +	Enter the CANID for mailbox 4
> +	Default value is set to 0x123, change this as required.
> +
> +config DA8XX_PRU_CANID_MBX5
> +	hex "CANID for mailbox 5"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	---help---
> +	Enter the CANID for mailbox 5
> +	Default value is set to 0x123, change this as required.
> +
> +config DA8XX_PRU_CANID_MBX6
> +	hex "CANID for mailbox 6"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	---help---
> +	Enter the CANID for mailbox 6
> +	Default value is set to 0x123, change this as required.
> +
> +config DA8XX_PRU_CANID_MBX7
> +	hex "CANID for mailbox 7"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	---help---
> +	Enter the CANID for mailbox 7
> +	Default value is set to 0x123, change this as required.
Why is filling the mailboxes the job of kernel config?

Regards,
Kurt
