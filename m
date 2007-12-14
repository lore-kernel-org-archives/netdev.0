From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHES 0/3]: DCCP patches for 2.6.25
Date: Fri, 14 Dec 2007 11:29:14 -0800 (PST)
Message-ID: <20071214.112914.174597446.davem@davemloft.net>
References: <1197596522-14600-1-git-send-email-acme@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53121
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761344AbXLNT3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 14:29:25 -0500
In-Reply-To: <1197596522-14600-1-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 13 Dec 2007 23:41:59 -0200

> 	Please consider pulling from:
> 
> master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

Pulled, but could you please reformat Gerrit's changelog entries in
the future?  They have these 80+ long lines which are painful to read
in ascii email clients and in terminal output.

I'll do this by hand during my next rebase for this case, but I will
push back when I see it again in future pull requests.
