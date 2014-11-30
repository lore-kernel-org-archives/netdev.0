From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] configure: Add check for the doc tools
Date: Sun, 30 Nov 2014 09:51:09 -0800
Message-ID: <20141130095109.2110836a@urahara>
References: <1417363705-560-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:44836 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293AbaK3RvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 12:51:19 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so9559971pad.15
        for <netdev@vger.kernel.org>; Sun, 30 Nov 2014 09:51:19 -0800 (PST)
In-Reply-To: <1417363705-560-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 30 Nov 2014 18:08:25 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> Added checking existence of the doc files converters.
> If the XXX tool exists then HAVE_XXX:=y will be written
> to the Config file. Example of the configure script output:
> 
> TC schedulers
>  ATM	no
>  IPT	using xtables
>  IPSET  yes
> 
> iptables modules directory: /usr/lib/iptables
> libc has setns: yes
> SELinux support: no
> 
> Docs
>  latex: no
>  WARNING: no docs can be built from LaTeX files
>  sgml2html: yes
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Applied
