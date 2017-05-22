From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 9/9] ipv6: remove unused variables in esp6
Date: Mon, 22 May 2017 12:59:32 +0200
Message-ID: <20170522105932.GE2631@secunet.com>
References: <20170519165556.483-1-sthemmin@microsoft.com>
 <20170519165556.483-10-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50306 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752181AbdEVK7f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 06:59:35 -0400
Content-Disposition: inline
In-Reply-To: <20170519165556.483-10-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 09:55:56AM -0700, Stephen Hemminger wrote:
> Resolves warnings:
> net/ipv6/esp6.c: In function ‘esp_ssg_unref’:
> net/ipv6/esp6.c:121:10: warning: variable ‘seqhi’ set but not used [-Wunused-but-set-variable]
> net/ipv6/esp6.c: In function ‘esp6_output_head’:
> net/ipv6/esp6.c:227:21: warning: variable ‘esph’ set but not used [-Wunused-but-set-variable]
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied to ipsec-next, thanks!
