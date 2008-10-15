From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: fix net_generic array leak
Date: Tue, 14 Oct 2008 22:54:59 -0700 (PDT)
Message-ID: <20081014.225459.18563762.davem@davemloft.net>
References: <20081015041522.GD24058@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@openvz.org, den@openvz.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39151
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751243AbYJOFzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 01:55:23 -0400
In-Reply-To: <20081015041522.GD24058@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 15 Oct 2008 08:15:22 +0400

> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks Alexey.
