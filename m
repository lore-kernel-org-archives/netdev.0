From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 3/3] ip-route man: add usage and description for
 lwtunnel encap attributes
Date: Fri, 16 Oct 2015 16:16:08 -0700
Message-ID: <20151016161608.492dfdee@xeon-e3>
References: <cover.1444907416.git.tgraf@suug.ch>
	<32616276616701280f2d6da44f0cbaf7fb93f5bf.1444907416.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	jbenc@redhat.com, mengke.liu@intel.com, tom@herbertland.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33744 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbbJPXP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 19:15:56 -0400
Received: by pabrc13 with SMTP id rc13so132714600pab.0
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 16:15:56 -0700 (PDT)
In-Reply-To: <32616276616701280f2d6da44f0cbaf7fb93f5bf.1444907416.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Oct 2015 13:13:40 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch updates ip-route man page with lwtunnel encap
> usage and description, covering MPLS and IP encapsulation.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

I applied all 3 patches. The first one into master (since it might be useful for
other code), and other two to net-next.
