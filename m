From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 0/4] A few more man pages and documentation
 fixup
Date: Tue, 3 Nov 2015 16:31:30 -0800
Message-ID: <20151103163130.5331c60f@xeon-e3>
References: <27f028ea7dbe4d078e9cb57b3d6fb335@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:24190 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754983AbbKDAb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 19:31:26 -0500
In-Reply-To: <27f028ea7dbe4d078e9cb57b3d6fb335@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Oct 2015 09:55:20 +0000
Phil Sutter <phil@nwl.cc> wrote:

> This series adds man pages for ifcfg, genl and ifstat utilities. Some of
> them have already been submitted once in 2013[1] but weren't picked up
> for unknown reasons.
> 
> Along with this comes a final patch fixing bridge fdb help text.
> 
> 
> [1]: http://lists.openwall.net/netdev/2013/05/27/102
> 
> Phil Sutter (4):
>   ifcfg: add manpage
>   genl: add manpage
>   ifstat: add manpage
>   bridge: fdb: minor syntax fix in help text
> 
>  bridge/fdb.c      |  6 ++---
>  man/man8/genl.8   | 77 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  man/man8/ifcfg.8  | 48 ++++++++++++++++++++++++++++++++++
>  man/man8/ifstat.8 | 59 ++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 187 insertions(+), 3 deletions(-)
>  create mode 100644 man/man8/genl.8
>  create mode 100644 man/man8/ifcfg.8
>  create mode 100644 man/man8/ifstat.8
> 

Applied thanks
