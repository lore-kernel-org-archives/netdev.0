From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH v2 0/8] Updated patchset with Thomas' comments
Date: Mon, 25 Sep 2006 15:18:03 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609251516240.26346@d.namei>
References: <20060925180412.715069000@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, tgraf@suug.ch,
	jmorris@redhat.com, sds@epoch.ncsc.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:37562 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751521AbWIYTSH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 15:18:07 -0400
To: Paul Moore <paul.moore@hp.com>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060925180412.715069000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 25 Sep 2006, paul.moore@hp.com wrote:

> This is an updated patchset which takes into account Thomas' comments.  This
> includes the addition of two new patches in the patchset which add a new
> Netlink interface as well as correct the list of interfaces in the large
> comment block at the top of include/net/netlink.h.
> 
> Please consider these patches for 2.6.19, thanks.

All patches -

Acked-by: James Morris <jmorris@namei.org>


Dave, I think these should be applied now and queued for 2.6.19.



-- 
James Morris
<jmorris@namei.org>
