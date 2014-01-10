From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iproute2: finish support for bonding
 attributes
Date: Thu, 9 Jan 2014 23:10:19 -0800
Message-ID: <20140109231019.22078419@nehalam.linuxnetplumber.net>
References: <20140104024538.3123.21977.stgit@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, jiri@resnulli.us
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:51122 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbaAJHKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 02:10:21 -0500
Received: by mail-pa0-f48.google.com with SMTP id lf10so2063393pab.7
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 23:10:21 -0800 (PST)
In-Reply-To: <20140104024538.3123.21977.stgit@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 03 Jan 2014 18:45:38 -0800
Scott Feldman <sfeldma@cumulusnetworks.com> wrote:

> Add support for bonding attributes just added to net-next.
> On set, allow string or number value for enumerated attributes.
> On show, use always use string value for attribute.
> 
> Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>

Applied to net-next-for-3.13 branch
