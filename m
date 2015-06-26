From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [ANNOUNCE] iproute2 4.1.0
Date: Fri, 26 Jun 2015 15:33:49 -0700
Message-ID: <20150626153349.2b0152c9@urahara>
References: <20150626130616.5a350099@urahara>
	<558DC8D7.4080803@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35808 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbbFZWdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 18:33:43 -0400
Received: by pdbci14 with SMTP id ci14so82186963pdb.2
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 15:33:43 -0700 (PDT)
In-Reply-To: <558DC8D7.4080803@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Jun 2015 14:49:11 -0700
roopa <roopa@cumulusnetworks.com> wrote:

> Hi Stephen,
> 
> I don't see the below fix in the 4.1 tarball you point below:
> https://patchwork.ozlabs.org/patch/479743/
> 
> I am not sure yet if there was a problem with my submission. I intended 
> for it to go into 4.1.
> 
> Thanks,
> Roopa

That is held off I thought mpls needed net-next (4.2) not 4.1.
It is merged into master (post 4.1).
