From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: compat_mmsghdr must be used in sys_recvmmsg
Date: Wed, 02 Dec 2009 01:23:47 -0800 (PST)
Message-ID: <20091202.012347.25441075.davem@davemloft.net>
References: <1259693246-30341-1-git-send-email-acme@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jean-mickael.guerin@6wind.com,
	acme@redhat.com
To: acme@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55307
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753485AbZLBJXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 04:23:41 -0500
In-Reply-To: <1259693246-30341-1-git-send-email-acme@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@infradead.org>
Date: Tue,  1 Dec 2009 16:47:26 -0200

> From: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
> 
> Both to traverse the entries and to set the msg_len field.
> 
> Commiter note: folded two patches and avoided one branch repeating the
> compat test.
> 
> Signed-off-by: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied.
