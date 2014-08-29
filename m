From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH 0/4] net: stmmac: Enable Intel Quark SoC X1000 Ethernet
 support
Date: Fri, 29 Aug 2014 01:28:14 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C2B6E7189@PGSMSX102.gar.corp.intel.com>
References: <cover.1409123378.git.hock.leong.kweh@intel.com>
 <53FDD4A4.5020603@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Ong, Boon Leong" <boon.leong.ong@intel.com>,
	Rayagond K <rayagond@vayavyalabs.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53FDD4A4.5020603@st.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Giuseppe CAVALLARO [mailto:peppe.cavallaro@st.com]
> Sent: Wednesday, August 27, 2014 8:53 PM
> To: Kweh, Hock Leong; David S. Miller
> Cc: netdev@vger.kernel.org; LKML; Ong, Boon Leong; Rayagond K
> Subject: Re: [PATCH 0/4] net: stmmac: Enable Intel Quark SoC X1000 Ethernet
> support
> 
> On 8/27/2014 12:32 PM, Kweh Hock Leong wrote:
> 
> hello and thx for these patches that at first glance look ok to me.
> Just some minor remark, in the stmmac I try to align the function parameters
> with the open parenthesis (devm_kzalloc in your case in not aligned).
> Added on copy also Rayagond he tested PCI. I cannot do any test because I
> have no PCI cards.
> 
> peppe
> 

Hi, noted and will update that in the v2 patch. Looking forward to get more feedback
before sending out the second version. Thanks.


Regards,
Wilson
