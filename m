From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] i40e: fix call of ndo_dflt_bridge_getlink()
Date: Mon, 26 Sep 2016 09:46:39 +0200
Message-ID: <1fa5f12e-515d-a5d7-3aa0-3836eee3502c@6wind.com>
References: <1474301694-13477-1-git-send-email-nicolas.dichtel@6wind.com>
 <60c90efd-fab3-84cd-f6e1-f6bc710c5ab7@6wind.com>
 <1474666638.2389.18.camel@intel.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Huaibin Wang <huaibin.wang@6wind.com>,
        Scott Feldman <sfeldma@gmail.com>,
        Carolyn Wyborny <carolyn.wyborny@intel.com>,
        Catherine Sullivan <catherine.sullivan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37223 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbcIZHqm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 03:46:42 -0400
Received: by mail-wm0-f42.google.com with SMTP id b130so133573063wmc.0
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 00:46:41 -0700 (PDT)
In-Reply-To: <1474666638.2389.18.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/09/2016 à 23:37, Jeff Kirsher a écrit :
[snip]
> Yes, it needs to go through my tree.   Please send it to intel-wired-lan@li
> sts.osuosl.org mailing list, that way I can track it through our patchwork
Ok, will do. I didn't send it to this list the first time because this list is
marked as "moderated for non-subscribers" in the MAINTAINERS file.
