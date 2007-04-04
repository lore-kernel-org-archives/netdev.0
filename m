From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [-mm patch] make drivers/net/qla3xxx.c:PHY_DEVICES[] static
Date: Tue, 03 Apr 2007 22:34:12 -0400
Message-ID: <46130EA4.4000403@pobox.com>
References: <20070330010559.2a232d9a.akpm@linux-foundation.org> <20070331205540.GB14134@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-driver@qlogic.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40292 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966299AbXDDCeb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 22:34:31 -0400
In-Reply-To: <20070331205540.GB14134@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Fri, Mar 30, 2007 at 01:05:59AM -0700, Andrew Morton wrote:
>> ...
>> Changes since 2.6.21-rc5-mm2:
>> ...
>>  git-netdev-all.patch
>> ...
>>  git trees
>> ...
> 
> 
> This patch makes the needlessly global PHY_DEVICES[] static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> ---
> 
> BTW: Why is the name uppercase?

applied


