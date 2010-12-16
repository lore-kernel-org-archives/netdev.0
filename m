From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2 1/1] can: c_can: Added support for Bosch
	C_CAN	controller
Date: Thu, 16 Dec 2010 21:09:52 +0900
Message-ID: <070E08D3134344CBB04FC2F201E778B7@hacdom.okisemi.com>
References: <1292407130-19791-1-git-send-email-bhupesh.sharma@st.com>
	<4D09D7B1.9080906@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Bhupesh Sharma" <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>,
	"Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
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

On Thursday, December 16, 2010 6:11 PM, Wolfgang Grandegger wrote:

> Ah, oh, I just realized that the register layout is almost identical to
> the recently accepted *pch_can* driver. Tomoya, does pch_can use a c_can
> core? Well, then it makes really sense to have a generic c_can driver
> for the SPEAR, PCH, etc. Board specific details are handled via platform
> definition. This driver already provides that functionality, IFAICS.

Hi Wolfgang,

It seems pch_can similar to c_can.
However, sorry, I don't know if pch_can core is the same as c_can since LSI 
is provided by Intel.
If necessary, please contact to Intel.

Thanks,
---
Tomoya MORINAGA
OKI SEMICONDUCTOR CO., LTD.
