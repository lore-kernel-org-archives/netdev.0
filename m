From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v3 iproute2] bridge link: add option 'self'
Date: Mon, 8 Dec 2014 12:06:19 +0100
Message-ID: <20141208110619.GC1885@nanopsycho.brq.redhat.com>
References: <1417854061-4675-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, vyasevic@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:46699 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755122AbaLHLGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 06:06:22 -0500
Received: by mail-wg0-f42.google.com with SMTP id z12so5945787wgg.29
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 03:06:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1417854061-4675-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Dec 06, 2014 at 09:21:01AM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>Currently self is set internally only if hwmode is set.
>This makes it necessary for the hw to have a mode.
>There is no hwmode really required to go to hardware. So, introduce
>self for anybody who wants to target hardware.
>
>v1 -> v2
>    - fix a few bugs. Initialize flags to zero: this was required to
>    keep the current behaviour unchanged.
>
>v2 -> v3
>    - fix comment
>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com> 

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
