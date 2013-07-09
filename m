From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] tc-stab.8: Fix synopsis errors, an invalid escape, and
 incorrect English usge.
Date: Tue, 9 Jul 2013 09:08:50 -0700
Message-ID: <20130709090850.47cb896f@nehalam.linuxnetplumber.net>
References: <20130701000247.GA31460@thyrsus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: esr@thyrsus.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:58130 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab3GIQlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 12:41:23 -0400
Received: by mail-pd0-f179.google.com with SMTP id q10so5387660pdj.38
        for <netdev@vger.kernel.org>; Tue, 09 Jul 2013 09:41:22 -0700 (PDT)
In-Reply-To: <20130701000247.GA31460@thyrsus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 30 Jun 2013 20:02:47 -0400
"Eric S. Raymond" <esr@thyrsus.com> wrote:

> The command synopsis is regularized and part of it split off into an
> OPTIONS section.  This allows the page to lift to XML-DocBook.
> 
> An invalid \p escape was removed.
> 
> This page was written by someone who didn't understand the use of
> definite and indefinite articles in English, nor its punctuation rules.
> I've fixed these mistakes, and some glitches in punctuation and
> capitalization.
> ---
>  man/man8/tc-stab.8 | 60 +++++++++++++++++++++++++++---------------------------
>  1 file changed, 30 insertions(+), 30 deletions(-)
> 
Applied
