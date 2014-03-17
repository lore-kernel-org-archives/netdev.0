From: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next] ieee802154: properly
 unshare skbs in ieee802154 *_rcv functions
Date: Mon, 17 Mar 2014 17:44:43 +0100
Message-ID: <eeaae15acd1ace30c13238732c1b4262.squirrel@webmail.itwm.fhg.de>
References: <1395070888-1130-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
    <20140317162058.GA10857@omega>
Reply-To: phoebe.buckheister@itwm.fraunhofer.de
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net
To: "Alexander Aring" <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:57600 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754891AbaCQQoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 12:44:46 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s2HGijYa000593
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 17:44:45 +0100
In-Reply-To: <20140317162058.GA10857@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, March 17, 2014 5:21 pm, Alexander Aring wrote:
> Hi Phoebe,
>
> looks interesting but doens't apply on current net-next for me. :(
> I didn't test it yet.

Indeed, I've unwittingly tested whether it applies against a stale version
of net-next. Sorry for the inconvenience.
