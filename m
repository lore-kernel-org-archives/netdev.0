From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP event tracking via netlink...
Date: Wed, 2 Jan 2008 13:05:17 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801021304050.31652@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712051533050.3119@kivilampi-30.cs.helsinki.fi>
 <20071206.023346.256200942.davem@davemloft.net> <20071206092312.79a83208@freepuppy.rosehill>
 <20080102.002227.67777942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34892 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753989AbYABLFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 06:05:21 -0500
In-Reply-To: <20080102.002227.67777942.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jan 2008, David Miller wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Thu, 6 Dec 2007 09:23:12 -0800
> 
> > Tools and scripts for testing that generate graphs are at:
> > 	git://git.kernel.org/pub/scm/tcptest/tcptest
> 
> Did you move it somewhere else?
> 
> davem@sunset:~/src/GIT$ git clone git://git.kernel.org/pub/scm/tcptest/tcptest
> Initialized empty Git repository in /home/davem/src/GIT/tcptest/.git/
> fatal: The remote end hung up unexpectedly
> fetch-pack from 'git://git.kernel.org/pub/scm/tcptest/tcptest' failed.

.../network/ was missing from the path :-).

$ git-remote show origin
* remote origin
  URL: git://git.kernel.org/pub/scm/network/tcptest/tcptest.git
  Remote branch(es) merged with 'git pull' while on branch master
    master
  Tracked remote branches
    master


-- 
 i.
