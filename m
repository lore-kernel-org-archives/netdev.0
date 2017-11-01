From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: dsa: lan9303: Fix STP and flooding
 issues
Date: Wed, 01 Nov 2017 21:30:38 +0900 (KST)
Message-ID: <20171101.213038.799755298352005372.davem@davemloft.net>
References: <20171031144802.12686-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: privat@egil-hjelmeland.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171031144802.12686-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Date: Tue, 31 Oct 2017 15:47:59 +0100

> This patch set finishes the STP support, and fixes flooding issues.
> 
> Patch 1 fixes a flooding issue in the previous patch set.
> Patch 2 finishes STP support by adding a ALR entry.
> Patch 3 prevent duplicate flooding in HW and SW bridge.

Series applied, thank you.
