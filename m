From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: macb: Updated resource allocation function
 calls to new version of API.
Date: Tue, 03 Jan 2017 09:36:06 -0500 (EST)
Message-ID: <20170103.093606.1137374125355882400.davem@davemloft.net>
References: <1483360206-27699-1-git-send-email-bfolta@cadence.com>
        <SN1PR0701MB1951683572D31AD5678100E9CC6F0@SN1PR0701MB1951.namprd07.prod.outlook.com>
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
In-Reply-To: <SN1PR0701MB1951683572D31AD5678100E9CC6F0@SN1PR0701MB1951.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bartosz Folta <bfolta@cadence.com>
Date: Mon, 2 Jan 2017 12:41:50 +0000

> Changed function calls of resource allocation to new API. Changed way
> of setting DMA mask. Removed unnecessary sanity check.
> This patch is sent in regard to recently applied patch
> Commit 83a77e9ec4150ee4acc635638f7dedd9da523a26
> net: macb: Added PCI wrapper for Platform Driver.
> 
> Signed-off-by: Bartosz Folta <bfolta@cadence.com>

Applied.
