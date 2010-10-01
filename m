From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: Re: [PATCH 1/2] drivers/net/usb/qcusbnet: Checkpatch cleanups
Date: Fri, 01 Oct 2010 16:26:29 +0300
Message-ID: <4CA5E185.3090902@gmail.com>
References: <20100928171026.GB6083@google.com> <cover.1285727642.git.joe@perches.com> <0aa502d0e385f2333f8bc12dafdcde88e5ca0262.1285727642.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Elly Jones <ellyjones@google.com>, netdev@vger.kernel.org,
	dbrownell@users.sourceforge.net, mjg59@srcf.ucam.org,
	jglasgow@google.com, msb@google.com, olofj@google.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from darkstar.wilibox.com ([195.14.175.138]:60036 "EHLO
	darkstar.wilibox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754672Ab0JANgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 09:36:15 -0400
In-Reply-To: <0aa502d0e385f2333f8bc12dafdcde88e5ca0262.1285727642.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2010 05:39 AM, Joe Perches wrote:
> Whitespace and removal of KERNEL_VERSION tests
> Neaten DBG macro

Why not use dev_dbg istead of this ugly DBG macro?
