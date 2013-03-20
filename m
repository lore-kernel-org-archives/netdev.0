From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] rename configure.in to configure.ac
Date: Wed, 20 Mar 2013 08:29:02 -0700
Message-ID: <20130320082902.1f515a7e@nehalam.linuxnetplumber.net>
References: <1363359946-7703-1-git-send-email-yegorslists@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, buytenh@gnu.org
To: yegorslists@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:64945 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051Ab3CTP3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 11:29:09 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so650843pdj.41
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 08:29:09 -0700 (PDT)
In-Reply-To: <1363359946-7703-1-git-send-email-yegorslists@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Mar 2013 16:05:46 +0100
yegorslists@googlemail.com wrote:

> From: Yegor Yefremov <yegorslists@googlemail.com>
> 
> Automake 1.14 will likely drop support for the long-deprecated
> 'configure.in' name for the Autoconf input file.
> 
> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>

Ok, applied this and cleaned up some other debris in make stuff.
