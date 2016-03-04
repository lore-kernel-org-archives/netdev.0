From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 0/5] Misc minor documentation fixes
Date: Fri, 4 Mar 2016 15:37:07 -0800
Message-ID: <20160304153707.14450e23@xeon-e3>
References: <1457092361-17603-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:61695 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760552AbcCDXg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 18:36:59 -0500
In-Reply-To: <1457092361-17603-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  4 Mar 2016 12:52:36 +0100
Phil Sutter <phil@nwl.cc> wrote:

> The following five patches contain minor changes to documentation at
> various places. They are all unrelated, but being lazy as I am, I
> submit them in one go.
> 
> Phil Sutter (5):
>   tc: pedit: document branch control in help output
>   man: ip-link: Beef up VXLAN csum options a bit
>   man: tc-u32: Minor syntax fix
>   man: ip-route: Make synopsis consistent with description
>   doc, man: ip-rule: Remove incorrect statement about rule 0
> 
>  doc/ip-cref.tex        | 3 ---
>  man/man8/ip-link.8.in  | 6 +++---
>  man/man8/ip-route.8.in | 2 +-
>  man/man8/ip-rule.8     | 2 --
>  man/man8/tc-u32.8      | 1 +
>  tc/m_pedit.c           | 3 ++-
>  6 files changed, 7 insertions(+), 10 deletions(-)
> 

Applied
