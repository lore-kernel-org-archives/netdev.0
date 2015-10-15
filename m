From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH 1/3] libnetlink: introduce rta_nest and u8,u16,u64
 helpers for nesting within rtattr
Date: Thu, 15 Oct 2015 18:51:36 +0200
Message-ID: <20151015185136.57a1c8d0@griffin>
References: <cover.1444907416.git.tgraf@suug.ch>
	<da2d3d3f6b5241e383ca88a00cff2e0e21e796c4.1444907416.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, mengke.liu@intel.com,
	tom@herbertland.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9461 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753816AbbJOQvk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 12:51:40 -0400
In-Reply-To: <da2d3d3f6b5241e383ca88a00cff2e0e21e796c4.1444907416.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Oct 2015 13:13:38 +0200, Thomas Graf wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch introduces two new api's rta_nest and rta_nest_end to
> nest attributes inside a rta attribute represented by 'struct rtattr'
> as required to construct a nexthop. Also adds rta_addattr* variants
> for u8, u16 and u64 as needed to support encapsulation.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Acked-by: Jiri Benc <jbenc@redhat.com>

-- 
Jiri Benc
