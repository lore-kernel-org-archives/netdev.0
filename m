From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 v2 1/2] include: add linked list implementation
 from kernel
Date: Sun, 27 Mar 2016 11:00:47 -0700
Message-ID: <20160327110047.214fd2cb@xeon-e3>
References: <1458637341-3434-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com, hannes@stressinduktion.org,
	gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33258 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752915AbcC0SAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 14:00:32 -0400
Received: by mail-pf0-f173.google.com with SMTP id 4so120101738pfd.0
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2016 11:00:32 -0700 (PDT)
In-Reply-To: <1458637341-3434-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Mar 2016 10:02:20 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Rename hlist.h to list.h while adding it to be aligned with kernel
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
> - fix some checkpatch issues

Applied, I did cleanup extra blank line on devlink.c
There are still some whitespace issues in list.h which I ignored.
