From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [next-queue 4/7] ixgbe: enable relaxed ordering for SPARC
Date: Sat, 14 Mar 2015 08:23:32 -0400
Message-ID: <20150314122332.GA10072@oracle.com>
References: <1426291248-14739-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1426291248-14739-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, nhorman@redhat.com,
	sassmann@redhat.com, jogreene@redhat.com, kernel-team@fb.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23928 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbbCNMXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 08:23:44 -0400
Content-Disposition: inline
In-Reply-To: <1426291248-14739-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/13/15 17:00), Jeff Kirsher wrote:
> 
> This patch makes sure that relaxed ordering is not disabled when
> on SPARC, where it helps with performance.

Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
