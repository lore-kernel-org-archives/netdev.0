From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH net-next 1/3] net: stmmac: add gmac autoneg set for SGMII,
 TBI, and RTBI
Date: Thu, 07 Mar 2013 09:50:06 +0100
Message-ID: <513854BE.5000700@st.com>
References: <00c001cdf369$9b25bdf0$d17139d0$@samsung.com> <50F6568D.3060703@st.com> <01e201cdf5a3$1f3e1890$5dba49b0$@samsung.com> <50FFB094.5000100@st.com> <013e01cdfb47$8f5d2b30$ae178190$@samsung.com> <51277004.20702@st.com> <022601ce1a20$ff6b2290$fe4167b0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	kgene.kim@samsung.com, cpgs@samsung.com
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <022601ce1a20$ff6b2290$fe4167b0$%an@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/6/2013 5:13 AM, Byungho An wrote:
> Hello Peppe,
>> If you agree, you could also re-send *all* to the mailing list to
>> be finally reviewed.
>>
>
> Anyway, in my opinion, you can take them in your tree for now with my
> tested-by if you want. Of course, I'll implement additional patches as you
> requested on top of them for remained stuff such as SGMII, TBI, ethtool and
> so on.
> I think those should be separated for each purpose and we can add and modify
> after those two patches.

Ok Byungho, I'm preparing a new update for the stmmac that will also 
include the initial support for SGMII and RGMII. Thx to have tested it!

Obviously on top of these patches, feel free to add further code.
TBI and RTBI are not supported yet.


P.S. in this update I've also added the ethtool missing stuff ;-)

Peppe
