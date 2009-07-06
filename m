From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/7] jme: Some minor coding style consistency
 modifications
Date: Sun, 05 Jul 2009 19:51:05 -0700 (PDT)
Message-ID: <20090705.195105.92877513.davem@davemloft.net>
References: <20090702183223.CC05E5D0C6@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ethanhsiao@jmicron.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33025
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753172AbZGFCu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 22:50:58 -0400
In-Reply-To: <20090702183223.CC05E5D0C6@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I can't apply these patches as is.

They are a mix of bug fixes that might be legitimate for
net-2.6 and cleanups and other changes which are totally
inappropriate for net-2.6 (and therefore should be
targetted for net-next-2.6 instead).

Please resubmit this properly.  Thank you.
