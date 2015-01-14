From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute2 ss: Some thoughts about additional info output layout
Date: Wed, 14 Jan 2015 14:55:56 -0800
Message-ID: <20150114145556.1d33c9d9@urahara>
References: <20150108221240.GA23636@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:40737 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbbAOCwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 21:52:14 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so14524768pad.10
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 18:52:14 -0800 (PST)
In-Reply-To: <20150108221240.GA23636@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 9 Jan 2015 00:12:40 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> Hi,
> 
> I think that current output of ss utility visually looks little weird
> when additional info options were specified, so I feel that a lot of
> yours will say that it will break existing scripts of ss output parsing
> but I will try, so thats how I think ss output would looks better in
> case if additionally info options were specified (I am not sure how it
> would looks in the email) :

The current output is pretty much unparseable for options with ss.
For a parseable output generating JSON would be much better, I did that for
a couple of utilities.

I see no problem with having a better human format.
