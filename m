From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip rule: Add support for l3mdev rules
Date: Tue, 14 Jun 2016 17:33:20 -0700
Message-ID: <20160614173320.7d915b10@xeon-e3>
References: <1465580837-8743-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35418 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893AbcFOAdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 20:33:23 -0400
Received: by mail-pf0-f169.google.com with SMTP id c2so2624660pfa.2
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 17:33:23 -0700 (PDT)
In-Reply-To: <1465580837-8743-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Jun 2016 10:47:17 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Kernel commit 96c63fa7393d ("net: Add l3mdev rule") added support for
> the FRA_L3MDEV attribute. The attribute enables use of l3mdev rules
> which mean 'get table id from l3 master device'. This patch adds
> support to iproute2 to show, add and delete rules with this attribute.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied to net-next
