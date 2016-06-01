From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC 04/12] net: cls_bpf: add support for marking filters as
 hardware-only
Date: Wed, 1 Jun 2016 10:19:06 -0700
Message-ID: <574F190A.2020107@gmail.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
 <1464799814-4453-5-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36221 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbcFART0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 13:19:26 -0400
Received: by mail-pf0-f181.google.com with SMTP id f144so18845161pfa.3
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 10:19:26 -0700 (PDT)
In-Reply-To: <1464799814-4453-5-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-01 09:50 AM, Jakub Kicinski wrote:
> Add cls_bpf support for the TCA_CLS_FLAGS_SKIP_SW flag.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> ---

Looks good to me. Glad to see this worked out without too much pain
on the classifier side at least.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
