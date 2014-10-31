From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 1/1] ip-link: add switch to show human readable
 output
Date: Fri, 31 Oct 2014 12:31:15 -0700
Message-ID: <20141031123115.4cd13371@urahara>
References: <20141029224738.263e27bd@urahara>
	<1414660599-25707-1-git-send-email-mail@eworm.de>
	<20141031111753.2b524ebb@leda.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christian Hesse <mail@eworm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:42925 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756809AbaJaTb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 15:31:27 -0400
Received: by mail-pd0-f181.google.com with SMTP id y10so7749396pdj.26
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 12:31:27 -0700 (PDT)
In-Reply-To: <20141031111753.2b524ebb@leda.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 31 Oct 2014 11:17:53 +0100
Christian Hesse <mail@eworm.de> wrote:

> Stephen Hemminger <stephen@networkplumber.org> on Wed, 2014/10/29 22:47:
> > I like the idea as a concept  
> 
> Great! ;)
> 
> > but there are two issues:
> >   1. The IEC suffix is a rarely used thing and is non-standard
> >      for communications where K = 1000 M = 1000000 etc.
> >      Please just use standard suffices  
> 
> Removed the suffix in patch v3. Not sure if it is correct, though. I do use a
> base of 2, so K = 1024, M = 1048576, ...

No must be 1000 for communications (SI)


  http://en.wikipedia.org/wiki/Binary_prefix
