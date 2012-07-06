From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH can-next v4] em_canid: Ematch rule to match CAN frames
 according to their identifiers
Date: Fri, 06 Jul 2012 06:52:46 +0200
Message-ID: <4FF66F1E.5060203@hartkopp.net>
References: <4FF3C2AE.9010106@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Rostislav Lisovy <lisovy@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4FF3C2AE.9010106@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04.07.2012 06:12, Oliver Hartkopp wrote:

> This ematch makes it possible to classify CAN frames (AF_CAN) according
> to their identifiers. This functionality can not be easily achieved with
> existing classifiers, such as u32, because CAN identifier is always stored
> in native endianness, whereas u32 expects Network byte order.
> 
> Signed-off-by: Rostislav Lisovy <lisovy@gmail.com>
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>


This patch is originally from Rostislav and is already part of this can-next
pull request:

http://marc.info/?l=linux-netdev&m=134141429413608&w=2

Tnx & regards,
Oliver

