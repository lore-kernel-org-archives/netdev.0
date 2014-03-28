From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH v2 net] mac802154: stop tx queue before destroy workqueue
Date: Fri, 28 Mar 2014 14:20:29 +0100
Message-ID: <20140328132026.GA29114@omega.Speedport_W_921V_1_24_000>
References: <1395944600-18330-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:38579 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbaC1NUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 09:20:35 -0400
Received: by mail-bk0-f50.google.com with SMTP id w10so913359bkz.9
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 06:20:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1395944600-18330-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

please drop this patch... I having still some issues to unloading the
at86rf230 driver while transmitting... I don't giving up to fix that issue...

Sorry, I need some time to understand what's going on there.

- Alex
