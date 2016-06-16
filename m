From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH v2 0/2] Two cosmetic fixes in tc/m_action.c
Date: Thu, 16 Jun 2016 09:42:59 -0700
Message-ID: <20160616094259.5448aaf1@xeon-e3>
References: <1466031039-18411-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:59686 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752615AbcFPQmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 12:42:54 -0400
In-Reply-To: <1466031039-18411-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Jun 2016 00:50:37 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Found these when doing something else. Shouldn't cause any functional
> change.
> 
> Changes since v1:
> - Replace patch 1/2 with a better solution as suggested by Stephen
>   Hemminger.
> 
> Phil Sutter (2):
>   tc: m_action: Use C99 style initializers for struct req
>   tc: m_action: Drop unused variable nladdr in tc_action_gd()
> 
>  tc/m_action.c | 50 +++++++++++++++++++++++---------------------------
>  1 file changed, 23 insertions(+), 27 deletions(-)
> 

Applied
