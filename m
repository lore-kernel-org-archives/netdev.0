From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Mon, 14 Mar 2016 17:20:00 +0100
Message-ID: <56E6E4B0.8060408@st.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>
 <56DD8FBE.9010200@suse.de> <56DD99A4.5030004@st.com>
 <56DDA26C.3050301@suse.de> <56DDA3D5.3090209@st.com>
 <56DDB749.1020808@suse.de>
 <CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw@mail.gmail.com>
 <56DE7E1D.5070508@st.com>
 <CADhT+weKf+F98uxCQhRa2RfMm8+4p=rrNZc-Vf=w_HPycXto=A@mail.gmail.com>
 <CAAObsKD9HoEbtV_JMz_R=bcrQseDmhncRAWP9k8djksL-LMQqw@mail.gmail.com>
 <56DFE55B.2090806@st.com> <56DFE64B.8060606@st.com>
 <CAAObsKBr9SXg1-wr9O-ypR8JozdGpeAwfDLMeUKi8ozxkKyTXg@mail.gmail.com>
 <56DFF253.9050208@st.com> <56DFFA9E.7060602@st.com>
 <CAAObsKBUzBXcamEyup44N1bYUzGr_ZZTsYcD5x3PXb-2E00cGA@mail.gmail.com>
 <56E033C8.40506@st.com> <56E038CE.606@st.com>
 <CADhT+wcMpzA_Coj8Z5OQZsc3bF3a7yOmsbazQMPtcdUWkJSuCA@mail.gmail.com>
 <56E13AAB.2080900@st.com>
 <CADhT+wd=vcph2y_OxkGNO5EwHvN=kBy-BrfZHmNjZHww4LxmTg@mail.gmail.com>
 <56E28B5D.6000708@st.com>
 <CAAObsKB-tSCu5KMYk2Zi-oX9zMKEOwwT93sMkiZKiYvtexmHaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 =?UTF-8?B?SGVpa28gU3TDvGJuZXI=?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 =?UTF-8?B?RnJhbmsgU2Now6RmZXI=?= <fschaefer.oss-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
 "open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 Fabrice GASNIER <fabrice.gasnier-qxv4g6HH51o@public.gmane.org>,
 =?UTF-8?B?QW5kcmVhcyBGw6RyYmVy?= <afaerber-l3A5Bk7waGM@public.gmane.org>,
 LAKML <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
To: Tomeu Vizoso <tomeu-XCtybt49RKsYaV1qd6yewg@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <CAAObsKB-tSCu5KMYk2Zi-oX9zMKEOwwT93sMkiZKiYvtexmHaQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

Hi Tomeu

On 3/14/2016 12:43 PM, Tomeu Vizoso wrote:
> Hi Peppe,
>
> with that patch I don't see any difference at all in my setup.
>
> So to be clear, with these commits on top of next-20160314, I still
> get the hang during boot:
>
> 209afef6f0cd ARM: dts: rockchip: Add mdio node to ethernet node
> 2315acc6cf7f Revert "stmmac: first frame prep at the end of xmit routine"
> b5e08e810c63 stmmac: fix tx prepare for normal desc
> 37c15a31d850 i2c: immediately mark ourselves as registered
> 4342eec3c5a2 Add linux-next specific files for 20160314
>
> [   27.521026] WARNING: CPU: 1 PID: 0 at net/sched/sch_generic.c:303
> dev_watchdog+0x284/0x288
> [   27.529460] NETDEV WATCHDOG: eth0 (rk_gmac-dwmac): transmit queue 0 timed out

I do not reproduce the WATCHDOG but i am continuing to look at the code
to understand if normal descriptor management is ok or not. I keep you
informed.

Just an info, did you test with 2315acc6cf7f included? Just to
understand if it is introducing a problem. It works in case of
enhanced descriptors are used instead of.

>
> https://git.collabora.com/cgit/user/tomeu/linux.git/log/?h=broken-eth-on-rock2

thx I will take a look at this

Regards
Peppe
