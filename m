From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v7 10/10] ss: activate json_writer excluded logic
Date: Wed, 28 Oct 2015 11:39:41 +0900
Message-ID: <20151028113941.062d74a3@samsung9>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
	<1441913708-15532-11-git-send-email-matthias.tafelmeier@gmx.net>
	<20151027132103.GI26876@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>,
	netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36449 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754305AbbJ1Cjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 22:39:53 -0400
Received: by pacfv9 with SMTP id fv9so251705480pac.3
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 19:39:49 -0700 (PDT)
In-Reply-To: <20151027132103.GI26876@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Oct 2015 14:21:03 +0100
Phil Sutter <phil@nwl.cc> wrote:

> On Thu, Sep 10, 2015 at 09:35:08PM +0200, Matthias Tafelmeier wrote:
> > This small patch extends the lib json_writer module for formerly
> > deactivated functionality.  
> 
> Why was it deactivated in the first place?

The code came from another project that wasn't using this
function.
