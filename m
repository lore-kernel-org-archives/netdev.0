From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: macb: Added PCI wrapper for Platform Driver.
Date: Sat, 17 Dec 2016 10:24:45 -0500 (EST)
Message-ID: <20161217.102445.1094535405180691442.davem@davemloft.net>
References: <1481648560-25927-1-git-send-email-bfolta@cadence.com>
        <SN1PR0701MB19516D29452ABA2695B2F061CC9A0@SN1PR0701MB1951.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, niklas.cassel@axis.com,
        alexandre.torgue@st.com, satananda.burla@caviumnetworks.com,
        rvatsavayi@caviumnetworks.com, simon.horman@netronome.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        rafalo@cadence.com
To: bfolta@cadence.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <SN1PR0701MB19516D29452ABA2695B2F061CC9A0@SN1PR0701MB1951.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bartosz Folta <bfolta@cadence.com>
Date: Wed, 14 Dec 2016 06:39:15 +0000

> There are hardware PCI implementations of Cadence GEM network
> controller. This patch will allow to use such hardware with reuse of
> existing Platform Driver.
> 
> Signed-off-by: Bartosz Folta <bfolta@cadence.com>
> ---
> Changed in v3:
> Fixed dependencies in Kconfig.
> ---
> Changed in v2:
> Respin to net-next. Changed patch formatting.

Applied.
