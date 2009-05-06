From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] slip: Clean up create and destroy
Date: Wed, 06 May 2009 16:41:28 -0700 (PDT)
Message-ID: <20090506.164128.169552937.davem@davemloft.net>
References: <20090506230204.24979.21110.stgit@t61.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58134
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751692AbZEFXld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 19:41:33 -0400
In-Reply-To: <20090506230204.24979.21110.stgit@t61.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Thu, 07 May 2009 00:02:51 +0100

> Comments on the approach welcomed - not ready to do anything with yet but want
> to see if folks think this is a good approach to sorting the slip mess out

Looks great to me.

Tons better than the rickety mess of code that manages that
array of devices.
