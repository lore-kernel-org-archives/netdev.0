From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash
 list depth
Date: Fri, 19 Apr 2013 07:45:45 -0700
Message-ID: <1366382745.16391.3.camel@edumazet-glaptop>
References: <20130418213637.14296.43143.stgit@dragon>
	 <20130418213732.14296.36026.stgit@dragon>
	 <1366366287.3205.98.camel@edumazet-glaptop>
	 <1366373950.26911.134.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:58171 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030601Ab3DSOps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 10:45:48 -0400
Received: by mail-pd0-f169.google.com with SMTP id 14so463527pdc.28
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 07:45:47 -0700 (PDT)
In-Reply-To: <1366373950.26911.134.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 14:19 +0200, Jesper Dangaard Brouer wrote:

> What is a reasonable max depth value for you?
> 

Current one is OK.
