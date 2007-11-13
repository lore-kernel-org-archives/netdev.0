From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 05/05] ipv6: RFC4214 Support (3)
Date: Tue, 13 Nov 2007 12:53:12 -0800
Message-ID: <20071113125312.4c4d1391@freepuppy.rosehill>
References: <473371B3.5030908@yahoo.com>
	<4734FCEF.3080301@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: osprey67 <osprey67@yahoo.com>, netdev@vger.kernel.org
To: osprey67 <osprey67@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57208 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757789AbXKMUzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 15:55:06 -0500
In-Reply-To: <4734FCEF.3080301@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 09 Nov 2007 16:35:59 -0800
osprey67 <osprey67@yahoo.com> wrote:

> From: Fred L. Templin <fred.l.templin@boeing.com>
> 
> This message attaches the combined diffs from
> messages 01/05 through 04/05. This file should be
> suitable for use with the patch utility.
> 
> Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
> 

Isn't increasing the size of struct ip_tunnel_parm
going to cause kernel ABI changes?

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
