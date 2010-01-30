From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can: add support for CAN interface cards
	based	on the PLX90xx PCI bridge
Date: Sat, 30 Jan 2010 19:48:54 +0100
Message-ID: <4B647F16.9000105@grandegger.com>
References: <1264758309-1632-1-git-send-email-chebl@star.inp.nsk.su>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Pavel B. Cheblakov" <P.B.Cheblakov-tHBF8D5G73F4OK5fxMSSsQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1264758309-1632-1-git-send-email-chebl-LmX6Lu7C9G7nhuLbLO4Grw@public.gmane.org>
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

Hi Pavel,

Pavel B. Cheblakov wrote:
> From: Pavel Cheblakov <P.B.Cheblakov-tHBF8D5G73F4OK5fxMSSsQ@public.gmane.org>
> 
> This driver is for CAN interface cards based on the PLX90xx PCI bridge.
> Driver supports now:
>  - Adlink PCI-7841/cPCI-7841 card (http://www.adlinktech.com/)
>  - Adlink PCI-7841/cPCI-7841 SE card
>  - Marathon CAN-bus-PCI card (http://www.marathon.ru/)
>  - TEWS TECHNOLOGIES TPMC810 card (http://www.tews.com/)
> 
> Signed-off-by: Pavel Cheblakov <P.B.Cheblakov-tHBF8D5G73F4OK5fxMSSsQ@public.gmane.org>

We already discussed this patch on the Socketcan mailing list and it's
OK from my point of view. Please fix the minor issues reported by Daniel
Baluta. To v2 of the patch you can then add directly my
"Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>"

Thanks for your contribution.

Wolfgang.
