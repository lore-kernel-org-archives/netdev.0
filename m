From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: RE: About bittiming calculation result
Date: Tue, 8 Feb 2011 13:11:44 +0900
Message-ID: <B50CC78E66FD4D1FA262EDC22C21C0D0@hacdom.okisemi.com>
References: <cover.1296818921.git.segoon@openwall.com><a6800dc8b0daed78256f98f52844cbbb48f4a76d.1296818921.git.segoon@openwall.com><20110204124233.GB334@e-circ.dyndns.org><20110204.130649.112613896.davem@davemloft.net><5009516791F146C49C73FAC57C437313@hacdom.okisemi.com><4D4FDEF9.2030305@grandegger.com>
	<E2BAACFF191C4175854E6B2EB9135BE5@hacdom.okisemi.com>
	<D5ECB3C7A6F99444980976A8C6D896384DEE2BE1A7@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "'Bhupesh SHARMA'" <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>,
	"'Wolfgang Grandegger'" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384DEE2BE1A7-8vAmw3ZAcdzhJTuQ9jeba9BPR1lH4CV8@public.gmane.org>
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

Hi  Bhupesh,

On Tuesday, February 08, 2011 12:30 PM, Bhupesh SHARMA wrote:
> AFAIK pch uses the Bosch C_CAN core internally.
> As per Bosch C_CAN user manual tseg1= prop_seg + phase_seg1 
> So, ideally tseg1_min should be 2. My version of Bosch C_CAN 
> driver Uses the value 2.

Thank you for your suggestions.
I will submit the patch.

With Best Regards,
-----------------------------------------
Tomoya MORINAGA
OKI SEMICONDUCTOR CO., LTD.
