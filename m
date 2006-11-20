From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/4] atl1: Build files for Attansic L1 driver
Date: Mon, 20 Nov 2006 21:04:48 +0100
Message-ID: <20061120200448.GA15720@electric-eye.fr.zoreil.com>
References: <20061119202915.GB29736@osprey.hogchain.net> <20061119152432.a85d4166.randy.dunlap@oracle.com> <456145DA.804@redhat.com> <4561CCA6.8080209@oracle.com> <4561D59F.5020206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Jay Cliburn <jacliburn@bellsouth.net>, jeff@garzik.org,
	shemminger@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:28582 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S966626AbWKTUIr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 15:08:47 -0500
To: Chris Snook <csnook@redhat.com>
Content-Disposition: inline
In-Reply-To: <4561D59F.5020206@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Snook <csnook@redhat.com> :
[...]
> To be precise, mii-tool is deprecated, in favor of ethtool.  There are 

$ man mii-tool
[...]
       -v, --verbose
              Display  more  detailed  MII status information.  If used twice,
                                                                ^^^^^^^^^^^^^
              also display raw MII register contents.
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Is there a similar feature in ethtool ?

-- 
Ueimor
