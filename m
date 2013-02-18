From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tg3: Remove define and single use of
 GET_CHIP_REV_ID
Date: Mon, 18 Feb 2013 12:46:17 -0500 (EST)
Message-ID: <20130218.124617.418052148242224119.davem@davemloft.net>
References: <dea1c655b2c1380821aae6cd8438ad742ddf6e12.1361049158.git.joe@perches.com>
	<1361051064.2240.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, mcarlson@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mchan@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361051064.2240.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Sat, 16 Feb 2013 13:44:24 -0800

> On Sat, 2013-02-16 at 13:20 -0800, Joe Perches wrote:
>> It's the same value as tp->pci_chip_rev_id so use that
>> instead.  This makes all CHIPREV_ID_<foo> tests the same.
>> 
>> Signed-off-by: Joe Perches <joe@perches.com> 
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied.
