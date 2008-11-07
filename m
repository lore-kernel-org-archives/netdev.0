From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [net-next] kernel bug at dev.c:4021
Date: Fri, 7 Nov 2008 17:07:11 -0600
Message-ID: <20081107170711.2b12189c@osprey.hogchain.net>
References: <20081107154407.43165cc4@osprey.hogchain.net>
	<20081107223907.GA18677@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost05.isp.att.net ([204.127.217.105]:60216 "EHLO
	fmailhost05.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbYKGXHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 18:07:14 -0500
In-Reply-To: <20081107223907.GA18677@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 8 Nov 2008 01:39:07 +0300
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> Do git-revert ae33bc40c0d96d02f51a996482ea7e41c5152695 meanwhile.

Yep, that was it.  Thanks Alexey.
