From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: Re: [PATCH] benet: Fix compile warnnings in
 drivers/net/benet/be_ethtool.c
Date: Fri, 26 Mar 2010 22:46:18 +0530
Message-ID: <20100326171616.GA20879@serverengines.com>
References: <20100326061259.GB30341@localhost.localdomain>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-drivers@serverengines.com, sathyap@serverengines.com
To: wzt.wzt@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:34777 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531Ab0CZRQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 13:16:25 -0400
Content-Disposition: inline
In-Reply-To: <20100326061259.GB30341@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/03/10 14:12 +0800, wzt.wzt@gmail.com wrote:
> Fix the following warnings:
> 
> be_ethtool.c:493: warning: integer constant is too large for 'long' type
> be_ethtool.c:493: warning: integer constant is too large for 'long' type
> 
> Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>

I would suggest using be2net instead of benet during the commit. 
be2net: Fix compile warnnings in drivers/net/benet/be_ethtool.c

Acked-by: Ajit Khaparde <ajitk@serverengines.com>
