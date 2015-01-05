From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH] net: flow: Guard against accessing non-existent
 attributes
Date: Mon, 5 Jan 2015 11:04:03 +0900
Message-ID: <20150105020401.GA15716@vergenet.net>
References: <1419819455-19109-1-git-send-email-simon.horman@netronome.com>
 <54A1951A.2070209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:47428 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950AbbAECEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 21:04:14 -0500
Received: by mail-pd0-f177.google.com with SMTP id ft15so27004799pdb.22
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 18:04:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54A1951A.2070209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2014 at 09:53:30AM -0800, John Fastabend wrote:
> On 12/28/2014 06:17 PM, Simon Horman wrote:
> >Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >---
> >  net/core/flow_table.c | 11 +++++++++++
> >  1 file changed, 11 insertions(+)
> 
> Great thanks. I rolled it into the patches I should hopefully have
> ready to submit later today.
> 
> By the way I got this working on rocker now so we can test it easier,
> I'll post the driver updates as well.

Great, excellent news.
