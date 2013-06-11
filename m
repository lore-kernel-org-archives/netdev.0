From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qmi_wwan/cdc_ether: let qmi_wwan handle the Huawei
 E1820
Date: Tue, 11 Jun 2013 02:44:09 -0700 (PDT)
Message-ID: <20130611.024409.2108676661902347182.davem@davemloft.net>
References: <1370516222-11566-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, graham.inggs@uct.ac.za,
	linux-usb@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061Ab3FKJoJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 05:44:09 -0400
In-Reply-To: <1370516222-11566-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu,  6 Jun 2013 12:57:02 +0200

> Another QMI speaking Qualcomm based device, which should be
> driven by qmi_wwan, while cdc_ether should ignore it.
 ...
> Reported-by: Graham Inggs <graham.inggs@uct.ac.za>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied, thanks.
