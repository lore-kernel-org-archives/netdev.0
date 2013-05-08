From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] net: frag, fix race conditions in LRU list maintenance
Date: Wed, 8 May 2013 17:32:27 +0200
Message-ID: <20130508173227.0f773360@redhat.com>
References: <20130505145622.9351.86587.stgit@zurg>
	<20130506093318.679f5557@redhat.com>
	<20130506.110800.1388239604905052651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: khlebnikov@openvz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6714 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755040Ab3EHPcf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 May 2013 11:32:35 -0400
In-Reply-To: <20130506.110800.1388239604905052651.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 06 May 2013 11:08:00 -0400 (EDT) David Miller <davem@davemloft.net> wrote:

> I sorted out the conflicts but someone needs to double-check
> my work.

Looks good to me.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
