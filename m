From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v3] ibmveth: Add function to enable live MAC address
 changes
Date: Tue, 3 Mar 2015 09:11:14 +0100
Message-ID: <20150303081114.GA2045@nanopsycho.orion>
References: <1425318972-19455-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	brking@linux.vnet.ibm.com, davem@davemloft.net
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38495 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbbCCILV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 03:11:21 -0500
Received: by wiwh11 with SMTP id h11so20696808wiw.3
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 00:11:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1425318972-19455-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 02, 2015 at 06:56:12PM CET, tlfalcon@linux.vnet.ibm.com wrote:
>Add a function that will enable changing the MAC address
>of an ibmveth interface while it is still running.
>
>Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
