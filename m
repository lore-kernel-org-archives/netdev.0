From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Multicast Routing in IPV4
Date: Fri, 2 May 2008 22:42:58 +0300 (EEST)
Message-ID: <alpine.LRH.1.10.0805022241420.10670@netcore.fi>
References: <31436f4a0805012349j50d0fdeenf2c51603120f7f1a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:48173 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932248AbYEBTnG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 15:43:06 -0400
In-Reply-To: <31436f4a0805012349j50d0fdeenf2c51603120f7f1a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 May 2008, David Shwatrz wrote:
> Could anybody recommend  some PIM based daemon which is known to work
> with IPv4 multicast routing in Linux ?  A  solution which will accomplish
> the basic functionalities of IPV4 multicast routing with 2.6 kernel will do.

XORP works fine as a PIM-SM router here.  XORP may not be the best 
routing protocol suite for BGP, OSPF, and the like, but based on my 
experience, multicast routing has been OK.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
