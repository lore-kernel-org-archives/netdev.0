From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 2/7] secid reconciliation-v02: Add LSM hooks
Date: Fri, 8 Sep 2006 16:10:07 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609081609210.7675@d.namei>
References: <45019F5C.3030102@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:54179 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751185AbWIHUKJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 16:10:09 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <45019F5C.3030102@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 8 Sep 2006, Venkat Yekkirala wrote:

> Add skb_policy_check and skb_netfilter_check hooks to LSM to enable
> reconciliation of the various security identifiers as well as enforce
> flow control on inbound (INPUT/FORWARD) and outbound (OUTPUT/FORWARD)
> traffic.

Is there any way you can send patches without "format=flowed" in the 
content-type?  On two mailers I've tried, the patches get mangled.



- James
-- 
James Morris
<jmorris@namei.org>
