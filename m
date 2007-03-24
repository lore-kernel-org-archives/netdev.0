From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/5 2.6.21-rc4] l2tp: pppol2tp kbuild changes
Date: Sat, 24 Mar 2007 15:01:03 +0100
Message-ID: <46052F1F.1060501@trash.net>
References: <200703232307.l2NN7Rj4010817@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54168 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbXCXOBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 10:01:07 -0400
In-Reply-To: <200703232307.l2NN7Rj4010817@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> [PPPOL2TP]: Modify kbuild for the new pppol2tp driver.
> 
> This patch adds a new config option, CONFIG_PPPOL2TP and adds
> if_pppol2tp.h to the list of exported headers.


This leaves the tree in a non-compiling state. Please fold into
the patch that actually adds the source files.

