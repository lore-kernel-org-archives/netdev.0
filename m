From: Thomas Graf <tgraf@suug.ch>
Subject: Re: status of route matching work?
Date: Wed, 15 Nov 2006 09:39:31 +0100
Message-ID: <20061115083931.GT8693@postel.suug.ch>
References: <F8900C78-45E3-4818-B7EA-DF14516CF876@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52428 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S966695AbWKOIjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 03:39:11 -0500
To: Kumar Gala <galak@kernel.crashing.org>
Content-Disposition: inline
In-Reply-To: <F8900C78-45E3-4818-B7EA-DF14516CF876@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Kumar Gala <galak@kernel.crashing.org> 2006-11-14 15:08
> And was wondering what the status of this work was.  I'm interested  
> in being able to force packets for a local address out a real  
> ethernet device.

I'm working on it. For now, use SO_BINDTODEVICE.
