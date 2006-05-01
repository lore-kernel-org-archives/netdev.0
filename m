From: "Ian Brown" <ianbrn@gmail.com>
Subject: wireless softmac origin (net/ieee80211/softmac)
Date: Mon, 1 May 2006 17:19:17 +0300
Message-ID: <d0383f90605010719p616243d0l8da568c02815f504@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from uproxy.gmail.com ([66.249.92.175]:5956 "EHLO uproxy.gmail.com")
	by vger.kernel.org with ESMTP id S932104AbWEAOTS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 10:19:18 -0400
Received: by uproxy.gmail.com with SMTP id c2so1941854ugf
        for <netdev@vger.kernel.org>; Mon, 01 May 2006 07:19:17 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
I am looking at 2.6.17-rc3 kernel.
 I wonder: what is the origin of softmac in
2.6.17-rc3 kernel ?
I see in the *.c files under that folder:
Copyright (c) 2005, 2006 Johannes Berg <johannes@sipsolutions.net>
 *                          Joseph Jezak <josejx@gentoo.org>
 *                          Larry Finger <Larry.Finger@lwfinger.net>
 *                          Danny van Dyk <kugelfang@gentoo.org>
 *                          Michael Buesch <mbuesch@freenet.de>

Is this softmac layer was written from scratch ? or was it
taken (fully/partially) from softmac in the devicescape linux kernel stack ?
http://devicescape.com/

Best,
IB
