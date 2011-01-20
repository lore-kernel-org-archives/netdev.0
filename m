From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: MultiPath TCP in the Linux Kernel
Date: Thu, 20 Jan 2011 16:38:25 +0100
Message-ID: <7e28a5ddc16848dcd98c05351113304f@localhost>
References: <201101201509.34536.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <bonding-devel@lists.sourceforge.net>,
	<linux-sctp@vger.kernel.org>
To: <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:50908 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755736Ab1ATPi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 10:38:28 -0500
In-Reply-To: <201101201509.34536.christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 20 Jan 2011 15:09:34 +0100, Christoph Paasch wrote:

> Hi all,

> 

> The IETF is developing a new transport layer solution, MultiPath TCP,

> which 

> allows to efficiently exploit several Internet paths between a pair of

> hosts, 

> while presenting a single TCP connection to the application layer.

> 

> At the UCLouvain in Belgium we are developping the support for MultiPath

> TCP 

> in the Linux Kernel. The implementation is a major extension to the

Linux

> TCP-

> stack.



Hello Christoph,



if you want that your work becomes part of the official network stack you

should align your effort on the official Linux way. This means you should

split your work and publish patches on this maillinglist.



Cheers, Hagen
