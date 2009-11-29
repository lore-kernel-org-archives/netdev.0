From: David Miller <davem@davemloft.net>
Subject: Re: [patch]reset_resume for cdc-ether
Date: Sun, 29 Nov 2009 00:18:07 -0800 (PST)
Message-ID: <20091129.001807.121313784.davem@davemloft.net>
References: <200911241159.02098.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44850
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751017AbZK2ISB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 03:18:01 -0500
In-Reply-To: <200911241159.02098.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Tue, 24 Nov 2009 11:59:02 +0100

> commit 31deb426ccea8faf91f4373c1f12c98bb0d82c73
> Author: Oliver Neukum <oliver@neukum.org>
> Date:   Tue Nov 24 08:30:41 2009 +0100
> 
>     cdc-ether:imlement reset_resume()
>     
>     Normal resume can do double duty as reset_resume() for this driver

David B., ACK, NACK, indifferent?
