From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [IPROUTE][IP]: enabled to manipulate the flags of
 IFA_F_HOMEADDRESS or IFA_F_NODAD from ip.
Date: Wed, 7 Mar 2007 14:21:38 -0800
Message-ID: <20070307142138.6c23eb53@freekitty>
References: <20070308.031543.465784743.takamiya@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nakam@linux-ipv6.org
To: Noriaki TAKAMIYA <takamiya@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34508 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965698AbXCGWVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 17:21:41 -0500
In-Reply-To: <20070308.031543.465784743.takamiya@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 08 Mar 2007 03:15:43 +0900 (JST)
Noriaki TAKAMIYA <takamiya@linux-ipv6.org> wrote:

> Hi, 
> 
>   This patch enables ip command to add IFA_F_HOMEADDRESS and
>   IFA_F_NODAD flags while adding the IPv6 address.
> 
> Signed-off-by: Noriaki TAKAMIYA<takamiya@po.ntts.co.jp>
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
>

applied, thanks

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
