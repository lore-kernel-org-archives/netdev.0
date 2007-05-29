From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] b44: netpoll locking fix
Date: Tue, 29 May 2007 19:13:53 -0400
Message-ID: <20070529231353.GA18385@tuxdriver.com>
References: <20070529211458.GA31200@electric-eye.fr.zoreil.com> <20070529142734.3de0ef4f@freepuppy> <20070529222041.GB31200@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Gary Zambrano <zambrano@broadcom.com>, jgarzik@pobox.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3370 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561AbXE2X0N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 19:26:13 -0400
Content-Disposition: inline
In-Reply-To: <20070529222041.GB31200@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 30, 2007 at 12:20:41AM +0200, Francois Romieu wrote:

> 2. Hunk #5 clashes with John Linville's wireless-dev#master

Let's not worry too much about this fact -- I'll (make Michael)
fix-up things in my tree as appropriate. :-)

John
-- 
John W. Linville
linville@tuxdriver.com
