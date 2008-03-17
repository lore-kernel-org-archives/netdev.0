From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [PATCH 1/4] netxen: improve msi support
Date: Mon, 17 Mar 2008 11:48:58 -0700
Message-ID: <Pine.LNX.4.64.0803171142370.21440@unm84.unminc.com>
References: <Pine.LNX.4.64.0803120059270.7717@unm84.unminc.com>
 <Pine.LNX.4.64.0803120118400.7717@unm84.unminc.com> <47DE5F38.5040106@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:28175 "EHLO
	nxexch.unminc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751182AbYCQStU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 14:49:20 -0400
In-Reply-To: <47DE5F38.5040106@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 17 Mar 2008, Jeff Garzik wrote:

> ACK patches 1-4, but does not apply to #upstream-fixes (nor davem's net-2.6)
> 

Interesting why it didn't apply, since driver/net/netxen on git-web is showing same parent f305f789bb96ee6e35e71f58324b72abb7bd0b13 as I had in my work tree.

Lemme respin patches, if that helps.

Thanks,
-Dhananjay
