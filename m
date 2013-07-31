From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 5/5] net/usb/r8152: adjust relative ocp function
Date: Wed, 31 Jul 2013 14:50:09 -0700 (PDT)
Message-ID: <20130731.145009.1288090378736581370.davem@davemloft.net>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
	<1375262486-5373-1-git-send-email-hayeswang@realtek.com>
	<1375262486-5373-5-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33501 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760796Ab3GaVuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 17:50:10 -0400
In-Reply-To: <1375262486-5373-5-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 31 Jul 2013 17:21:26 +0800

>  - fix the conversion between cpu and __le32
>  - replace some pla_ocp and usb_ocp functions with generic_ocp function
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
