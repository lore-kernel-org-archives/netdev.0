From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Steps to integrate new 40G Network driver to the kernel tree
Date: Fri, 15 Apr 2011 17:54:29 -0700
Message-ID: <20110415175429.5e91fb59@nehalam>
References: <4DA8D9F6.2070908@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joyce Yu - System Software <joyce.yu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60876 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755515Ab1DPAyf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 20:54:35 -0400
In-Reply-To: <4DA8D9F6.2070908@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Apr 2011 16:51:18 -0700
Joyce Yu - System Software <joyce.yu@oracle.com> wrote:

> Hello,
> 
> We have a new 40G network Linux driver. What are the steps to integrate  
> it to the kernel tree?

There is a simple well documented process.
See the file SubmittingPatches in the kernel source Documentation directory.

Network drivers should be submitted to netdev list.
