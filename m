From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git 0/3] stmmac: review driver Koptions
Date: Wed, 15 Oct 2014 14:36:55 -0400 (EDT)
Message-ID: <20141015.143655.890510202184028269.davem@davemloft.net>
References: <1413361531-9182-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53267 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbaJOSg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 14:36:56 -0400
In-Reply-To: <1413361531-9182-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Wed, 15 Oct 2014 10:25:28 +0200

> These patches are to rework some Koption used for configuring
> the driver. Recently many options have been added and the main
> goal behind this work is to guarantee that the driver built fine
> on all the branches where it is present. All the Koption for
> platform drivers can be safely removed (for example never added
> for SPEAr). In that case, it will be possible to validate the
> build for all the platforms like STi avoiding failures.
> The patches have been tested on STi Boxes w/o issue at runtime.

Please resubmit these when the net-next tree re-opens.

Thank you.
