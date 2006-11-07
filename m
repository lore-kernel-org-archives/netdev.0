From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 6/8] subdance: correct initial and close hardware step.
Date: Tue, 07 Nov 2006 04:43:16 -0500
Message-ID: <45505534.904@garzik.org>
References: <200610202142.k9KLgDSI003729@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@icplus.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:16564 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1753918AbWKGJnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 04:43:18 -0500
To: akpm@osdl.org
In-Reply-To: <200610202142.k9KLgDSI003729@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Jesse Huang <jesse@icplus.com.tw>
> 
> Correct initial and close hardware step.  In some embedded system down and up
> IP100A will cause DMA crash.  We add some for safe down and up IP100A.
> 
> Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

applied


