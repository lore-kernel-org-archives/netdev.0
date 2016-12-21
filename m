From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: Applied changes according to review made by
 Andy Shevchenko.
Date: Wed, 21 Dec 2016 11:08:56 -0500 (EST)
Message-ID: <20161221.110856.890610349232988869.davem@davemloft.net>
References: <1482309315-582-1-git-send-email-bfolta@cadence.com>
        <SN1PR0701MB1951B994F86160A24C436F30CC930@SN1PR0701MB1951.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, niklas.cassel@axis.com,
        alexandre.torgue@st.com, satananda.burla@caviumnetworks.com,
        rvatsavayi@caviumnetworks.com, simon.horman@netronome.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        rafalo@cadence.com
To: bfolta@cadence.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59848 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755170AbcLUQI7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 11:08:59 -0500
In-Reply-To: <SN1PR0701MB1951B994F86160A24C436F30CC930@SN1PR0701MB1951.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bartosz Folta <bfolta@cadence.com>
Date: Wed, 21 Dec 2016 08:53:05 +0000

> This patch is sent in regard to recently applied patch
> Commit 83a77e9ec4150ee4acc635638f7dedd9da523a26
> net: macb: Added PCI wrapper for Platform Driver.
> Andy's review does not appear on mailing lists. I can't reference it.
> 
> Signed-off-by: Bartosz Folta <bfolta@cadence.com>

This commit log message and Subject line need a lot of improvement.

You should be saying what exactly you are doing, rather than "someone
said I should do this".  The latter gives the reader no information
whatsoever about what the patch is doing.
