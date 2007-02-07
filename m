From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH netdev#atl1 1/1] atl1: clean up extern, global scope declarations
Date: Wed, 07 Feb 2007 17:14:18 -0500
Message-ID: <45CA4F3A.5080000@garzik.org>
References: <20070207023453.GA2657@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, bunk@stusta.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37833 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422899AbXBGWOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 17:14:42 -0500
In-Reply-To: <20070207023453.GA2657@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn wrote:
> From: Jay Cliburn <jacliburn@bellsouth.net>
> 
> atl1: move extern to header file; make some global code static
> 
> Move an extern declaration to a header file.  Make needlessly global
> functions static.  Noticed by Adrian Bunk.
> 
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>

applied


