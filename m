From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v4 0/8] switchdev: add IPv4 routing offload
Date: Fri, 06 Mar 2015 07:43:44 -0800
Message-ID: <54F9CB30.3030603@gmail.com>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: sfeldma@gmail.com, netdev@vger.kernel.org, davem@davemloft.net,
	jiri@resnulli.us, roopa@cumulusnetworks.com,
	alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36825 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754871AbbCFPnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 10:43:45 -0500
Received: by padfa1 with SMTP id fa1so46254996pad.3
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 07:43:45 -0800 (PST)
In-Reply-To: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/2015 09:21 PM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> v4:
[snip]
>   - Rebase against Alex's latest FIB changes.  I think I did everything
>     correctly, and didn't run into any issues with testing, but I'd like
>     Alex to look over the changes and maybe follow-up with any cleanups.

I'll rebase my latest patches against your changes and submit a patch
for anything I find.

- Alex
