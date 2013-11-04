From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] cdc_mbim + qmi_wwan trivial fixes
Date: Mon, 04 Nov 2013 15:48:42 -0500 (EST)
Message-ID: <20131104.154842.937373087218100293.davem@davemloft.net>
References: <1383311936-20954-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org, oneukum@suse.de
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746Ab3KDUst convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 15:48:49 -0500
In-Reply-To: <1383311936-20954-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Fri,  1 Nov 2013 14:18:51 +0100

> This series fixes three problems Oliver pointed out during the
> review of the new huawei_cdc_ncm driver:
> http://patchwork.ozlabs.org/patch/278903/
>=20
> That innocent driver only used cdc_mbim as a blueprint, and
> all the blame should really have gone to me....
>=20
> I do have a similar fix for the manage_power issue in the
> cdc-wdm USB class driver as well.  It will be submitted to
> linux-usb as soon as Greg opens up his mailbox again :-)

Looks good, applied, thanks.
