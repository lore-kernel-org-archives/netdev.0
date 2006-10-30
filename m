From: James Morris <jmorris@namei.org>
Subject: Re: [patch 1/1] NetLabel: protect the CIPSOv4 socket option from
 setsockopt()
Date: Mon, 30 Oct 2006 13:58:35 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0610301357590.8348@d.namei>
References: <20061030180331.404950000@hp.com> <20061030180801.641867000@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@redhat.com,
	sds@epoch.ncsc.mil, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:44947 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1161374AbWJ3S6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 13:58:37 -0500
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <20061030180801.641867000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Oct 2006, paul.moore@hp.com wrote:

> From: Paul Moore <paul.moore@hp.com>
> 
> This patch makes two changes to protect applications from either removing or
> tampering with the CIPSOv4 IP option on a socket. 

Thanks.  Applied to:

git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/selinux-net-2.6.git




-- 
James Morris
<jmorris@namei.org>
