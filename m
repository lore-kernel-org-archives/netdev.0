From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 1/2] tg3: Remove define and single use of
 GET_CHIP_REV_ID
Date: Sat, 16 Feb 2013 13:44:24 -0800
Message-ID: <1361051064.2240.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <dea1c655b2c1380821aae6cd8438ad742ddf6e12.1361049158.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "Matt Carlson" <mcarlson@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Joe Perches" <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <dea1c655b2c1380821aae6cd8438ad742ddf6e12.1361049158.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-02-16 at 13:20 -0800, Joe Perches wrote:
> It's the same value as tp->pci_chip_rev_id so use that
> instead.  This makes all CHIPREV_ID_<foo> tests the same.
> 
> Signed-off-by: Joe Perches <joe@perches.com> 

Acked-by: Michael Chan <mchan@broadcom.com>
