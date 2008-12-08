From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: Nasty regression from .27.7 to .27.8: idle samba goes crazy
Date: Mon, 08 Dec 2008 20:19:37 +0100
Message-ID: <493D7349.10200@s5r6.in-berlin.de>
References: <pan.2008.12.08.06.18.57.357875@wizards.de> <200812080834.22924.rjw@sisk.pl> <pan.2008.12.08.08.07.29.439625@wizards.de> <493D4F5C.7020606@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Greg KH <greg@kroah.com>,
	stable@kernel.org
To: Holger Hoffstaette <holger@wizards.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:52828 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269AbYLHTTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 14:19:47 -0500
In-Reply-To: <493D4F5C.7020606@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On Monday, 8 of December 2008, Holger Hoffstaette wrote:
>>>> The system is a generic old single-core P4 box with a single SATA drive,
>>>> Gentoo userland and Samba is 3.0.33 (in async mode). The kernel has no
>>>> patches or binary drivers.

Holger, it may be unrelated to the issue, but to be sure:  Which network
card driver do you use?
-- 
Stefan Richter
-=====-==--- ==-- -=---
http://arcgraph.de/sr/
