From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next] ieee802154: properly
 unshare skbs in ieee802154 *_rcv functions
Date: Mon, 17 Mar 2014 17:21:01 +0100
Message-ID: <20140317162058.GA10857@omega>
References: <1395070888-1130-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net
To: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:60473 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754554AbaCQQVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 12:21:08 -0400
Received: by mail-ee0-f46.google.com with SMTP id t10so4318500eei.33
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 09:21:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1395070888-1130-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Phoebe,

looks interesting but doens't apply on current net-next for me. :(
I didn't test it yet.

line 444 in this patch looks different than current net-next one.

Maybe you can respin this patch before net-next is closed. Thanks.

- Alex
