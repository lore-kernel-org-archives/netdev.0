From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v3 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Tue, 11 Jan 2011 22:01:56 +0100
Message-ID: <4D2CC544.7090407@hartkopp.net>
References: <1294135195-9448-1-git-send-email-bhupesh.sharma@st.com>	<20110106.113356.102556872.davem@davemloft.net>
	<4D261AAA.5030005@grandegger.com> <4D261BA4.2020003@pengutronix.de>
	<4D262158.4030301@grandegger.com> <4D299583.10909@hartkopp.net>
	<4D29C8F6.5030806@grandegger.com>
	<D5ECB3C7A6F99444980976A8C6D896384DEAFA2D56@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384DEAFA2D56-8vAmw3ZAcdzhJTuQ9jeba9BPR1lH4CV8@public.gmane.org>
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

On 11.01.2011 05:13, Bhupesh SHARMA wrote:
>> From: Wolfgang Grandegger [mailto:wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org]
>> On 01/09/2011 12:01 PM, Oliver Hartkopp wrote:

>>> BTW. for the next submission of Bhupeshs patchset, i would propose to
>> name the
>>> driver 'ccan' instead of 'c_can', so that we have a
>>>
>>>     linux/drivers/net/can/ccan/...
>>>
>>> path.
>>
>> You are late ;-). Bosch named the controller *C_CAN* and therefore I
>> asked Bhupesh some time ago to change the file name and variable name
>> prefix from ccan to c_can.
> 
> Actually V1 of this patchset used the naming convention ccan.
> But as was rightly pointed out by Wolfgang and Mark, Bosch
> has officially named this core as C_CAN and the naming convention
> is kept as C_CAN throughout their user-manual and technical articles.
> IMHO, `c_can` seems to represent this Bosch core in a better way 
> than ccan.

Looks like there are really good reasons for the c_can naming :-)

Thanks for explanation & also sorry for the noise!

Best regards,
Oliver
