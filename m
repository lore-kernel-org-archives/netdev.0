From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bridge: check __vlan_vid_del for error
Date: Tue, 08 Sep 2015 22:32:56 -0700 (PDT)
Message-ID: <20150908.223256.1333552287101885924.davem@davemloft.net>
References: <1441502877-31972-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, sfeldma@gmail.com, jiri@resnulli.us
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbbIIFc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 01:32:57 -0400
In-Reply-To: <1441502877-31972-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Sat,  5 Sep 2015 21:27:57 -0400

> Since __vlan_del can return an error code, change its inner function
> __vlan_vid_del to return an eventual error from switchdev_port_obj_del.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks.
