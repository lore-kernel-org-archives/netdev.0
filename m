From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] net: thunderx: Miscellaneous fixes
Date: Thu, 09 Mar 2017 13:12:56 -0800 (PST)
Message-ID: <20170309.131256.1923856751370789132.davem@davemloft.net>
References: <1488890351-18493-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com
To: sunil.kovvuri@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488890351-18493-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: sunil.kovvuri@gmail.com
Date: Tue,  7 Mar 2017 18:09:07 +0530

> From: Sunil Goutham <sgoutham@cavium.com>
> 
> This patch set fixes multiple issues such as IOMMU
> translation faults when kernel is booted with IOMMU enabled
> on host, incorrect MAC ID reading from ACPI tables and IPv6
> UDP packet drop due to failure of checksum validation.

Series applied, thanks.
