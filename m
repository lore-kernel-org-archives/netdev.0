From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Fri, 11 Mar 2016 10:09:49 +0100
Message-ID: <56E28B5D.6000708@st.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>	<56DD7172.4000707@suse.de>	<2714888.1DdqvJZ8cb@diego>	<56DD7593.5060003@suse.de>	<56DD8176.2080603@st.com>	<56DD8FBE.9010200@suse.de>	<56DD99A4.5030004@st.com>	<56DDA26C.3050301@suse.de>	<56DDA3D5.3090209@st.com>	<56DDB749.1020808@suse.de>	<CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw@mail.gmail.com>	<56DE7E1D.5070508@st.com>	<CADhT+weKf+F98uxCQhRa2RfMm8+4p=rrNZc-Vf=w_HPycXto=A@mail.gmail.com>	<CAAObsKD9HoEbtV_JMz_R=bcrQseDmhncRAWP9k8djksL-LMQqw@mail.gmail.com>	<56DFE55B.2090806@st.com>	<56DFE64B.8060606@st.com>	<CAAObsKBr9SXg1-wr9O-ypR8JozdGpeAwfDLMeUKi8ozxkKyTXg@mail.gmail.com>	<56DFF253.9050208@st.com>	<56DFFA9E.7060602@st.com>	<CAAObsKBUzBXcamEyup44N1bYUzGr_ZZTsYcD5x3PXb-2E00cGA@mail.gmail.com>	<56E033C8.40506@st.c
 om>	<56E038CE.606@st.com>	<CADhT+wcMpzA_Coj8Z5OQZsc3bF3a7yOmsbazQMPtcdUWkJSuCA@mail.gmail.com>	<56E13AAB.2080900@st.com>
 <CADhT+wd=vcph2y_OxkGNO5EwHvN=kBy-BrfZHmNjZHww4LxmTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080008040906020605010002"
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 =?UTF-8?B?SGVpa28gU3TDvGJuZXI=?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 =?UTF-8?B?RnJhbmsgU2Now6RmZXI=?= <fschaefer.oss-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
 "open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 Fabrice GASNIER <fabrice.gasnier-qxv4g6HH51o@public.gmane.org>,
 =?UTF-8?B?QW5kcmVhcyBGw6RyYmVy?= <afaerber-l3A5Bk7waGM@public.gmane.org>,
 LAKML <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
To: Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tomeu Vizoso <tomeu-XCtybt49RKsYaV1qd6yewg@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <CADhT+wd=vcph2y_OxkGNO5EwHvN=kBy-BrfZHmNjZHww4LxmTg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

--------------080008040906020605010002
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit

On 3/10/2016 5:47 PM, Dinh Nguyen wrote:
> On Thu, Mar 10, 2016 at 3:13 AM, Giuseppe CAVALLARO
> <peppe.cavallaro-qxv4g6HH51o@public.gmane.org> wrote:
>> On 3/9/2016 5:31 PM, Dinh Nguyen wrote:
>>>
>>> On Wed, Mar 9, 2016 at 8:53 AM, Giuseppe CAVALLARO
>>> <peppe.cavallaro-qxv4g6HH51o@public.gmane.org> wrote:
>>>>
>>>> Hi Tomeu, Dinh, Andreas
>>>>
>>>> I need a sum and help from you to go ahead on the
>>>> tx timeout.
>>>>
>>>> The "stmmac: MDIO fixes" seems to be the candidate to
>>>> fix the phy connection and I will send the V2 asap (Andreas' comment).
>>>>
>>>> So, supposing the probe is ok and phy is connected,
>>>> I need your input ...
>>>>
>>>>    Tomeu: after revering the 0e80bdc9a72d (stmmac: first frame
>>>>           prep at the end of xmit routine) the network is
>>>>           not stable and there is a timeout after a while.
>>>>           The box has 3.50 with normal desc settings.
>>>>
>>>>    Dinh: the network is ok, I wonder if you can share a boot
>>>>          log just to understand if the normal or enhanced
>>>>          descriptors are used.
>>>>
>>>
>>> Here it is:
>>
>> ...
>>>
>>> [    0.850523] stmmac - user ID: 0x10, Synopsys ID: 0x37
>>> [    0.855570]  Ring mode enabled
>>> [    0.858611]  DMA HW capability register supported
>>> [    0.863128]  Enhanced/Alternate descriptors
>>> [    0.867482]  Enabled extended descriptors
>>> [    0.871482]  RX Checksum Offload Engine supported (type 2)
>>> [    0.876948]  TX Checksum insertion supported
>>> [    0.881204]  Enable RX Mitigation via HW Watchdog Timer
>>> [    0.886863] socfpga-dwmac ff702000.ethernet eth0: No MDIO subnode found
>>> [    0.899090] libphy: stmmac: probed
>>> [    0.902484] eth0: PHY ID 00221611 at 4 IRQ POLL (stmmac-0:04) active
>>
>>
>> Thx Dinh, so you are using the Enhanced/Alternate descriptors
>> I am debugging on my side on a setup with normal descriptors, I let you
>> know
>>
>
> Doesn't the printout "Enhanced/Alternate descriptors"  mean that I'm using
> Enhanced/Alternate descriptors?

yes this means that you have the Databook 3.70a and, from the HW
capability register, the driver will use the Enhanced/Alternate
descriptors. This is the same HW I am using on my side where the
stmmac is working fine.

In the case where it is failing on net-next, although on Databook 3.50a,
the HW  capability register says that there is no enhanced descriptors
and the driver uses the normal ones.

Tomeu, I kindly ask you to try the patch attached. I found a bug on Tx
path for normal descriptors. Please let me know if this help.
Also let me know if we actually need to revert the 0e80bdc9a72d.

I am trying to find some HW where test the normal descriptors to
speed-up the tests on my side directly.

Let me know and thx in advance.

Regards,
Peppe

>
> Dinh
>

--------------080008040906020605010002
Content-Type: text/x-patch;
	name="0001-stmmac-fix-tx-prepare-for-normal-desc.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-stmmac-fix-tx-prepare-for-normal-desc.patch"

>From ed3e38befc5500e05f46e1d52ea20a0b8d3829f3 Mon Sep 17 00:00:00 2001
From: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Date: Thu, 10 Mar 2016 14:57:48 +0100
Subject: [PATCH (linux-sti-4.1)] stmmac: fix tx prepare for normal desc

This patch fixes a bug inside when use the normal descriptors.
While preparing the tx descriptor the frame size was not
properly set.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index e13228f..432b3f1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -197,13 +197,15 @@ static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 				  bool csum_flag, int mode, bool tx_own,
 				  bool ls)
 {
-	unsigned int tdes1 = p->des1;
+	unsigned int tdes1;
 
 	if (mode == STMMAC_CHAIN_MODE)
 		norm_set_tx_desc_len_on_chain(p, len);
 	else
 		norm_set_tx_desc_len_on_ring(p, len);
 
+	tdes1 = p->des1;
+
 	if (is_fs)
 		tdes1 |= TDES1_FIRST_SEGMENT;
 	else
-- 
1.7.4.4


--------------080008040906020605010002
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linux-rockchip mailing list
Linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
http://lists.infradead.org/mailman/listinfo/linux-rockchip

--------------080008040906020605010002--
