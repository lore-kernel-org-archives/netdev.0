From: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2] net/macb: add DT support
Date: Mon, 05 Dec 2011 12:36:43 +0100
Message-ID: <4EDCACCB.4010608@atmel.com>
References: <1322846050-4543-1-git-send-email-nicolas.ferre@atmel.com>
 <1322847782-22650-1-git-send-email-nicolas.ferre@atmel.com>
 <20111202.125832.1208514279272697863.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, jamie-wmLquQDDieKakBO8gow8eQ@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20111202.125832.1208514279272697863.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/02/2011 06:58 PM, David Miller :
> From: Nicolas Ferre<nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
> Date: Fri,  2 Dec 2011 18:43:02 +0100
>
>> From: Jean-Christophe PLAGNIOL-VILLARD<plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>
>>
>> Allow the device tree to provide the mac address and the phy mode.
>>
>> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD<plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>
>> [nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org: change "compatible" node property, doc and DT hwaddr]
>> Signed-off-by: Nicolas Ferre<nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
>> Cc: Jamie Iles<jamie-wmLquQDDieKakBO8gow8eQ@public.gmane.org>
>> ---
>> v2: modify macb_get_hwaddr_dt() parameter
>
> You'll have to respin these two macb patches, as they don't apply properly
> to the net-next tree which is where they should be targetted.

David,

In fact, the patches are designed to be added on top of Jamie's rework 
of the macb driver that is now in Arnd's "arm-soc" git tree (for-next 
branch). You discussed with him here:

http://www.spinics.net/lists/arm-kernel/msg118717.html

Should I go this path also or wait for this material to be merged and 
update on net-next at this time (after 3.3 merge window...)?

Best regards,
-- 
Nicolas Ferre
