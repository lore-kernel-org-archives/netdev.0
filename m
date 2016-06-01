From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC 08/12] net: cls_bpf: allow offloaded filters to update stats
Date: Wed, 1 Jun 2016 10:20:14 -0700
Message-ID: <574F194E.2040007@gmail.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
 <1464799814-4453-9-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33850 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753715AbcFARUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 13:20:31 -0400
Received: by mail-pf0-f176.google.com with SMTP id 62so18873394pfd.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 10:20:31 -0700 (PDT)
In-Reply-To: <1464799814-4453-9-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-01 09:50 AM, Jakub Kicinski wrote:
> Call into offloaded filters to update stats.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> ---


Acked-by: John Fastabend <john.r.fastabend@intel.com>
