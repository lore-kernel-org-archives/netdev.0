From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] Changed action labels to [action ] format
Date: Fri, 10 Oct 2014 23:59:57 +0300
Message-ID: <CAMw6YJLKqO8+v-LN8BhpKzgnu7erbgGmo2ou+SAX9fHcomqQZA@mail.gmail.com>
References: <1412959916-32169-1-git-send-email-vadim4j@gmail.com>
	<20141010155648.1f1b51bf@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:45732 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbaJJVAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 17:00:00 -0400
Received: by mail-la0-f45.google.com with SMTP id q1so3995755lam.4
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 13:59:59 -0700 (PDT)
In-Reply-To: <20141010155648.1f1b51bf@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

But the scripts can be easy rewritten ?

On Fri, Oct 10, 2014 at 11:56 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri, 10 Oct 2014 19:51:56 +0300
> Vadim Kochan <vadim4j@gmail.com> wrote:
>
>> The reasons for this change were:
>>     - different ip utils uses different labels for action: Deleted/delete
>>     - make an action labels to be easy found in logs
>
> Fine in concept. But people do stupid things like parse the output of commands.
> I am loathe to make cosmetic change.
>
