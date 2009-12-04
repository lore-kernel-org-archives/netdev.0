From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tcp_* settings change on the fly?
Date: Fri, 4 Dec 2009 14:25:59 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912041425240.7024@wel-95.cs.helsinki.fi>
References: <4B1839CE.2080000@shiftmail.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Asdo <asdo@shiftmail.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51264 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754585AbZLDMZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 07:25:53 -0500
In-Reply-To: <4B1839CE.2080000@shiftmail.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Dec 2009, Asdo wrote:

> Hi all,
> if I change some of the settings
> /proc/sys/net/ipv4/tcp_*
> does the change apply "on the fly" on existing established connections, or do
> I have to kill and reestablish the connections to have the change?

It pretty much depends on with particular setting we talk here.

-- 
 i.
