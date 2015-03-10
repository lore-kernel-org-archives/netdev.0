From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next] switchdev: add netlink flags to IPv4 FIB add op
Date: Tue, 10 Mar 2015 11:26:20 +0900
Message-ID: <20150310022618.GC20856@vergenet.net>
References: <1425934749-18567-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@resnulli.us, jhs@mojatatu.com,
	roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:37525 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbbCJC0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 22:26:31 -0400
Received: by paceu11 with SMTP id eu11so63424425pac.4
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 19:26:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1425934749-18567-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 09, 2015 at 01:59:09PM -0700, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> Pass in the netlink flags (NLM_F_*) into switchdev driver for IPv4 FIB add op
> to allow driver to 1) optimize hardware updates, 2) handle ip route prepend
> and append commands correctly.
> 
> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Suggested-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>
