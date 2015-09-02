From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: parsing ethtool output in programs/scripts
Date: Tue, 1 Sep 2015 17:33:34 -0700
Message-ID: <20150901173334.3f9bdc4e@urahara>
References: <55E6413A.2060809@unix-beratung.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bwh@kernel.org, netdev@vger.kernel.org
To: Robert Urban <urban@unix-beratung.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33049 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbbIBAdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 20:33:23 -0400
Received: by paap5 with SMTP id p5so4795456paa.0
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 17:33:23 -0700 (PDT)
In-Reply-To: <55E6413A.2060809@unix-beratung.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Sep 2015 02:22:18 +0200
Robert Urban <urban@unix-beratung.de> wrote:

> Hello,
> 
> I wish you would consider adding a switch to ethtool (and the corresponding
> functionality) to produce output in machine-readable format.
> 
> This would be *extremely* useful.
> 
> Why not add the "--machine-readable" switch mentioned here:

Why not use json and --json flag like iproute2 tools are getting (gradually).
