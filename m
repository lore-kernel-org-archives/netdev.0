From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] igb: reduce Rx header size
Date: Thu, 02 Aug 2012 17:52:47 +0200
Message-ID: <1343922767.9299.234.camel@edumazet-glaptop>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1342912142-11130-8-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1343920538.9299.200.camel@edumazet-glaptop>  <501AA00E.3010400@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36151 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055Ab2HBPwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 11:52:51 -0400
Received: by eeil10 with SMTP id l10so2440834eei.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 08:52:50 -0700 (PDT)
In-Reply-To: <501AA00E.3010400@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-02 at 08:43 -0700, Alexander Duyck wrote:

> Would there be any problems with us running this through Jeff's tree for
> testing prior to applying this?  I'm just wanting to do some testing
> internally for any performance regressions due to this change.

Sure, I was expecting this exactly, sorry if it was not clear.

( by the way, I am more interested on the second patch I just sent )

Thanks !
