From: Patrice Chotard <patrice.chotard-qxv4g6HH51o@public.gmane.org>
Subject: Re: [STLinux Kernel] [PATCH 18/19] stmmac: dwmac-sti: Remove obsolete
 STi platforms
Date: Tue, 18 Oct 2016 10:59:15 +0200
Message-ID: <7b0ce054-b30b-3a8e-23b9-ca3a33a55e31@st.com>
References: <1473859677-9231-1-git-send-email-peter.griffin@linaro.org>
 <1473859677-9231-19-git-send-email-peter.griffin@linaro.org>
 <20160923151142.GG9176@rob-hp-laptop>
 <dcbb8065-b272-0a2f-8efb-c55217712caf@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <kernel-F5mvAk5X5gdBDgjK7y7TUQ@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Peter Griffin <peter.griffin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Peppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <dcbb8065-b272-0a2f-8efb-c55217712caf-qxv4g6HH51o@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 10/18/2016 10:05 AM, Patrice Chotard wrote:
> 
> 
> On 09/23/2016 05:11 PM, Rob Herring wrote:
>> On Wed, Sep 14, 2016 at 02:27:56PM +0100, Peter Griffin wrote:
>>> This patch removes support for STiH415/6 SoC's from the
>>> dwmac-sti driver and dt binding doc, as support for these
>>> platforms is being removed from the kernel. It also removes
>>> STiD127 related code, which has never actually been supported
>>> upstream.
>>>
>>> Signed-off-by: Peter Griffin <peter.griffin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>>> Cc: <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
>>> Cc: <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
>>> Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
>>> ---
>>>  .../devicetree/bindings/net/sti-dwmac.txt          |  3 +-
>>
>> Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> 
> 
> Applied on sti-dt-for-4.10 branch


Sorry, i did a mistake, these patch should go in stmmac tree.
Peppe or Alexandre will you take care of it ?

Thanks
> 
> Thanks 
> 
>>
>>>  drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    | 37 ----------------------
>>>  2 files changed, 1 insertion(+), 39 deletions(-)
> 
> _______________________________________________
> Kernel mailing list
> Kernel-F5mvAk5X5gdBDgjK7y7TUQ@public.gmane.org
> http://www.stlinux.com/mailman/listinfo/kernel
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
