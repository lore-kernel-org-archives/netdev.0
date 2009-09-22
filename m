From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH V2 0/3] at91_can: add support for Atmel's CAN controller
	on AT91SAM9263
Date: Wed, 23 Sep 2009 00:07:58 +0200
Message-ID: <4AB94ABE.6070409@pengutronix.de>
References: <1253180254-11910-1-git-send-email-mkl@pengutronix.de>	
	<4AB20679.2040602@grandegger.com> <4AB209CB.10707@pengutronix.de>
	<cd73a99e0909211431k37429a70o4efaac7104f7d526@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Victor <linux-PelNFVqkFnVyf+4FbqDuWQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Andrew Victor <avictor.za-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <cd73a99e0909211431k37429a70o4efaac7104f7d526-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hey Andrew,

Andrew Victor wrote:
>>>> Marc Kleine-Budde (3):
>>>>       at91sam9263: add at91_can device to generic device definition
>>>>       at91sam9263ek: activate at91 CAN controller
>>>>       at91_can: add driver for Atmel's CAN controller on AT91SAM9263
>>> I have just added my "signed-off-by" for the Socket-CAN patch #3. Don't
>>> known who will take care of the other patches.
>> Thanks Wolfgang.
>>
>> Andrew, are the first two going throught the arm tree?
> 
> That would be best.
> Please submit them to Russell King's patch system.

done as:

5722	at91sam9263: add at91_can device to generic device definition
5723	at91sam9263ek: activate at91 CAN controller

Cheers, Marc

- --
Pengutronix e.K.                         | Marc Kleine-Budde           |
Linux Solutions for Science and Industry | Phone: +49-231-2826-924     |
Vertretung West/Dortmund                 | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686         | http://www.pengutronix.de   |
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkq5Sr4ACgkQjTAFq1RaXHNrLgCfeVy7xmi1UzdxGeWK3z4XRqMC
rjYAn2EK0LKhOe/S890W2bq6ElzPDNQL
=phat
-----END PGP SIGNATURE-----
