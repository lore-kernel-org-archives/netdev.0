From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] man ip-link: Add notice about local netns
 devices
Date: Fri, 27 Feb 2015 19:02:39 -0800
Message-ID: <20150227190239.485039cf@urahara>
References: <1424871982-31938-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:45363 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbbB1DCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 22:02:38 -0500
Received: by igjz20 with SMTP id z20so5303136igj.4
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 19:02:37 -0800 (PST)
In-Reply-To: <1424871982-31938-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Feb 2015 15:46:22 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Added some clarification why 'ip link set netns' can not
> change network namespace for some kind of devices.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Applied
