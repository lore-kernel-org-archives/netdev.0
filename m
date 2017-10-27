From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH net-next 2/2] bindings: net: stmmac: Add documentation for
 TSN parameters
Date: Fri, 27 Oct 2017 14:29:17 +0200
Message-ID: <de8781f7-39b1-8ba9-d0d0-ba89834697d3@st.com>
References: <cover.1508938927.git.joabreu@synopsys.com>
 <ef1d220cf792c74ae278e0200ca4763f9ab62d3e.1508938927.git.joabreu@synopsys.com>
 <c2a4a435-0b0b-4fa3-a69a-280f6d0c6427@gmail.com>
 <23152048-09fe-2950-e1ff-8cf90ca3f465@synopsys.com>
 <20171026090308.GD20299@lunn.ch>
 <867d6d43-9df7-4097-db5a-f2049236394f@synopsys.com>
 <20171026215629.GB8489@lunn.ch>
 <e14b8b79-465b-9cf3-4ecc-52de4781d9c0@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Rob Herring <robh+dt@kernel.org>
To: Jose Abreu <Jose.Abreu@synopsys.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e14b8b79-465b-9cf3-4ecc-52de4781d9c0@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

On 10/27/2017 11:05 AM, Jose Abreu wrote:
> I think we should take advantage of the fact that this is working
> and ready to be merged. Its just HW configuration but maybe it
> can serve as momentum for other drivers to also integrate this?

Let me propose to have it now in the next-next.

This support is for dwmac 5.x so no disturb for the common
driver APIs and there is no risk to have regressions, IMO.

IIUC, you already tested it on a real environment that
sounds to be very good progress.

Regards
Peppe

> Best Regards,
> Jose Miguel Abreu
