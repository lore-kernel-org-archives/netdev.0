From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: remove unnecessary code
Date: Thu, 12 Jan 2017 15:25:49 -0500 (EST)
Message-ID: <20170112.152549.1436993838110326721.davem@davemloft.net>
References: <20170112010902.GA9597@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56618 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750846AbdALU0B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:26:01 -0500
In-Reply-To: <20170112010902.GA9597@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 11 Jan 2017 17:09:02 -0800

> Remove code that's no longer needed.  It used to serve a purpose, which was
> to fix a link-related bug.  For a while now, the NIC firmware has had a
> more elegant fix for that bug.
> 
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>

Applied.
