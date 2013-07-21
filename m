From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [patch net-next v2 0/3] export device physical port id to userspace
Date: Sun, 21 Jul 2013 08:59:54 +0300
Message-ID: <CAJZOPZ+T=qZ3qsE-h3j_UTFi3byFQ4xKzLKN0prq83z6ZqkPmA@mail.gmail.com>
References: <1374342834-10814-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Narendra_K@dell.com,
	bhutchings@solarflare.com, john.r.fastabend@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f46.google.com ([209.85.128.46]:53922 "EHLO
	mail-qe0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010Ab3GUF7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 01:59:55 -0400
Received: by mail-qe0-f46.google.com with SMTP id nd7so3176399qeb.33
        for <netdev@vger.kernel.org>; Sat, 20 Jul 2013 22:59:54 -0700 (PDT)
In-Reply-To: <1374342834-10814-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 20, 2013 at 8:53 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> This patchset is based on patch by Narendra_K@Dell.com

Hi Jiri,

Just a small note to make we're not running (at least not foo fast...)
here... the patch you mentioned
is still not finalized I think. At least, as I mentioned there, lets
see it allows to modify
the current drivers that make use of the dev_id field to denote port number to
the new scheme,  before we build the 2nd floor of the building.

Or.
